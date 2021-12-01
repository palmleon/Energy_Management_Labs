#include "inc/dpm_policies.h"

int dpm_simulate(psm_t psm, dpm_policy_t sel_policy, dpm_timeout_params
		tparams, dpm_history_params hparams, dpm_last_active_params laparams, char* fwl)
{

	FILE *fp;
	psm_interval_t idle_period, prev_idle_period;
	psm_time_t history[DPM_HIST_WIND_SIZE];
	psm_time_t curr_time = 0;
	psm_state_t curr_state = PSM_STATE_ACTIVE;
    psm_state_t prev_state = PSM_STATE_ACTIVE;
    psm_energy_t e_total = 0;
    psm_energy_t e_tran;
    psm_energy_t e_tran_total = 0;
    psm_energy_t e_total_no_dpm = 0;
    psm_time_t t_tran_total = 0;
    psm_time_t t_waiting = 0;
	psm_time_t t_idle_ideal = 0;
    psm_time_t t_state[PSM_N_STATES] = {0};
    int n_tran_total = 0;

	fp = fopen(fwl, "r");
	if(!fp) {
		printf("[error] Can't open workload file %s!\n", fwl);
		return 0;
	}

	dpm_init_history(history);
    prev_idle_period.start = 0; prev_idle_period.end = 0;

    // main loop
    while(fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end) == 2) {

        t_idle_ideal += psm_duration(idle_period);
        //prev_state = PSM_STATE_ACTIVE; // at the beginning of each idle period, it is always active
        // for each instant until the end of the current idle period
		for (; curr_time < idle_period.end; curr_time++) {

            // compute next state
            if(!dpm_decide_state(&curr_state, curr_time, prev_idle_period, idle_period, history,
                        sel_policy, tparams, hparams, laparams)) {
                printf("[error] cannot decide next state!\n");
                return 0;
            }

            if (curr_state != prev_state) {
                if(!psm_tran_allowed(psm, prev_state, curr_state)) {
                    printf("[error] prohibited transition!\n");
                    printf("Current time: %f", curr_time);
                    return 0;
                }
                printf("%f: transition from %s to %s\n", curr_time, PSM_STATE_NAME(prev_state), PSM_STATE_NAME(curr_state));

                e_tran = psm_tran_energy(psm, prev_state, curr_state);
                e_tran_total += e_tran;
                t_tran_total += psm_tran_time(psm, prev_state, curr_state);
                n_tran_total++;
                e_total += psm_state_energy(psm, curr_state) + e_tran;
            } else {
                e_total += psm_state_energy(psm, curr_state);
            }
            e_total_no_dpm += psm_state_energy(psm, PSM_STATE_ACTIVE);
            
            // statistics of time units spent in each state
            t_state[curr_state]++;
            // time spent actively waiting for timeout expirations
            if(curr_state == PSM_STATE_ACTIVE && curr_time >=
                    idle_period.start) {
                t_waiting++;
            }
            prev_state = curr_state;
        }
        dpm_update_history(history, psm_duration(idle_period));
        prev_idle_period = idle_period;
    }
    fclose(fp);

    printf("[sim] Active time in profile = %.6lfs \n", (curr_time - t_idle_ideal) * PSM_TIME_UNIT);
    printf("[sim] Inactive time in profile = %.6lfs\n", t_idle_ideal * PSM_TIME_UNIT);
    printf("[sim] Total time = %.6lfs\n", curr_time * PSM_TIME_UNIT);
    printf("[sim] Timeout waiting time = %.6lfs\n", t_waiting * PSM_TIME_UNIT);
    for(int i = 0; i < PSM_N_STATES; i++) {
        printf("[sim] Total time in state %s = %.6lfs\n", PSM_STATE_NAME(i),
                t_state[i] * PSM_TIME_UNIT);
    }
    printf("[sim] Time overhead for transition = %.6lfs\n",t_tran_total * PSM_TIME_UNIT);
    printf("[sim] N. of transitions = %d\n", n_tran_total);
    printf("[sim] Energy for transitions = %.10fJ\n", e_tran_total * PSM_ENERGY_UNIT);
    printf("[sim] Energy w/o DPM = %.10fJ, Energy w DPM = %.10fJ\n",
            e_total_no_dpm * PSM_ENERGY_UNIT, e_total * PSM_ENERGY_UNIT);
	return 1;
}

int dpm_simulate_real(psm_t psm, dpm_policy_t sel_policy, dpm_timeout_params tparams, 
dpm_history_params hparams, dpm_last_active_params laparams, char* fwl)
{
    
	FILE *fp;
	psm_interval_t idle_period, prev_idle_period;
	psm_time_t history[DPM_HIST_WIND_SIZE];
	psm_time_t curr_time = 0;
	psm_state_t curr_state = PSM_STATE_ACTIVE;
    psm_state_t prev_state = PSM_STATE_ACTIVE;
    psm_energy_t e_total = 0;
    psm_energy_t e_tran;
    psm_energy_t e_tran_total = 0;
    psm_energy_t e_total_no_dpm = 0;
    psm_time_t t_tran_total = 0;
    psm_time_t t_waiting = 0;
	psm_time_t t_idle_ideal = 0;
    psm_time_t t_active_ideal = 0;          //time spent in active state ideally
    psm_time_t t_ideal_end = 0;             //time of the ideal end
    psm_time_t t_state[PSM_N_STATES] = {0};
    int n_tran_total = 0;

	fp = fopen(fwl, "r");
    int n_lines = 0;
	if(!fp) {
		printf("[error] Can't open workload file %s!\n", fwl);
		return 0;
	}

	dpm_init_history(history);
    prev_idle_period.start = 0; prev_idle_period.end = 0;

    while(fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end) == 2) { n_lines++; }

    //Allocate enough space to keep all the work packets
    dpm_work_packet *work_array = (dpm_work_packet*) malloc(sizeof(dpm_work_packet)*n_lines); 

    //Create the array of work packets that represents the workload model
    rewind(fp);
    work_array[0].start = 0;
    for (int line = 0; line < n_lines-1; line++){
        fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end);
        work_array[line].duration = idle_period.start - work_array[line].start;
        work_array[line+1].start = idle_period.end;

        //for stats only
        t_active_ideal += work_array[line].duration;
        t_idle_ideal += idle_period.end - idle_period.start;
    }
    fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end);
    work_array[n_lines-1].duration = idle_period.start - work_array[n_lines-1].start;
    e_total_no_dpm = idle_period.end * psm_state_energy(psm, PSM_STATE_ACTIVE);
    t_ideal_end = idle_period.end;
    t_active_ideal += work_array[n_lines-1].duration;
    t_idle_ideal += idle_period.end - idle_period.start;

    //Main loop: cycles until all work packets are completed
    int fifo[10];                   //fifo of packets arrived but not completed, it keeps only indexes
    int fifo_tail = 0;              //pointer to the tail of the fifo
    int work_packets_index = 0;     //index of next packet that will arrive
    int flag_idle_period = 0;
    
    while ((work_packets_index != n_lines || fifo_tail != 0) || curr_time < t_ideal_end ){
        
        //Add packets already arrived in previous cycles or in this current one
        while (work_packets_index < n_lines && work_array[work_packets_index].start - curr_time < PSM_TIME_UNIT){
            fifo[fifo_tail] = work_packets_index;
            work_packets_index++;
            fifo_tail++;
        }
        
        if (fifo_tail == 0) {
            //idle time
            //printf("%f\n", curr_time);
            if (!flag_idle_period){
                prev_idle_period = idle_period;
                idle_period.start = curr_time;
                flag_idle_period = 1;
            }
            
            if(!dpm_decide_state(&curr_state, curr_time, prev_idle_period, idle_period, history,
                        sel_policy, tparams, hparams, laparams)) {
                printf("[error] cannot decide next state!\n");
                return 0;
            }

            if (curr_state == PSM_STATE_ACTIVE){
                //time spent waiting during idle
                t_waiting++;
            }

            if (curr_state != prev_state) {
                if(!psm_tran_allowed(psm, prev_state, curr_state)) {
                    printf("[error] prohibited transition!\n");
                    printf("Current time: %f", curr_time);
                    return 0;
                }

                //printf("%f: transition from %s to %s\n", curr_time, PSM_STATE_NAME(prev_state), PSM_STATE_NAME(curr_state));
                //transition to low power states
                e_tran = psm_tran_energy(psm, prev_state, curr_state);
                e_tran_total += e_tran;
                e_total += e_tran;
                curr_time += psm_tran_time(psm, prev_state, curr_state);
                t_tran_total += psm_tran_time(psm, prev_state, curr_state);
                n_tran_total++;

            } else {
                
                t_state[curr_state]++;
                e_total += psm_state_energy(psm, curr_state);
                curr_time++;
            }
        }
        else {
            //work time
            if (flag_idle_period){
                idle_period.end = curr_time;
                flag_idle_period = 0;
            }
            
            if (curr_state != PSM_STATE_ACTIVE) {

                //transition to active
                curr_state = PSM_STATE_ACTIVE;
                //printf("%f: transition from %s to %s\n", curr_time, PSM_STATE_NAME(prev_state), PSM_STATE_NAME(curr_state));
                e_tran = psm_tran_energy(psm, prev_state, curr_state);
                e_tran_total += e_tran;
                e_total += e_tran;
                curr_time += psm_tran_time(psm, prev_state, curr_state);
                t_tran_total += psm_tran_time(psm, prev_state, curr_state);
                n_tran_total++;
            }
            prev_state = PSM_STATE_ACTIVE;
            curr_time += work_array[fifo[0]].duration;
            e_total += work_array[fifo[0]].duration * psm_state_energy(psm, curr_state);
            t_state[PSM_STATE_ACTIVE] += work_array[fifo[0]].duration;
            for (int g = 0; g < 10; fifo[g]=fifo[g+1], g++);
            fifo_tail--;
        }

        prev_state = curr_state;
    }
    
    fclose(fp);
    
    printf("[sim] Active time in profile = %.6lfs \n", t_active_ideal * PSM_TIME_UNIT);
    printf("[sim] Inactive time in profile = %.6lfs\n", t_idle_ideal * PSM_TIME_UNIT);
    printf("[sim] Total time = %.6lfs\n", curr_time * PSM_TIME_UNIT);
    printf("[sim] Timeout waiting time = %.6lfs\n", t_waiting * PSM_TIME_UNIT);
    for(int i = 0; i < PSM_N_STATES; i++) {
        printf("[sim] Total time in state %s = %.6lfs\n", PSM_STATE_NAME(i),
                t_state[i] * PSM_TIME_UNIT);
    }
    printf("[sim] Time overhead for transitions = %.6lfs\n",t_tran_total * PSM_TIME_UNIT);
    printf("[sim] N. of transitions = %d\n", n_tran_total);
    printf("[sim] Energy for transitions = %.10fJ\n", e_tran_total * PSM_ENERGY_UNIT);
    printf("[sim] Time w/o DPM = %.6fs, Time w DPM = %.6fs\n", 
            t_ideal_end * PSM_TIME_UNIT, curr_time * PSM_TIME_UNIT);
    printf("[sim] Energy w/o DPM = %.10fJ, Energy w DPM = %.10fJ\n",
            e_total_no_dpm * PSM_ENERGY_UNIT, e_total * PSM_ENERGY_UNIT);

	return 1;
}

int dpm_decide_state(psm_state_t *next_state, psm_time_t curr_time, psm_interval_t prev_idle_period,
        psm_interval_t idle_period, psm_time_t *history, dpm_policy_t policy,
        dpm_timeout_params tparams, dpm_history_params hparams, dpm_last_active_params laparams)
{
    switch (policy) {

        case DPM_TIMEOUT:
            /* Day 2: EDIT */
            if(curr_time >= idle_period.start + tparams.timeout) {
                *next_state = PSM_STATE_SLEEP;
            } else {
                *next_state = PSM_STATE_ACTIVE;
            }
            break;

        case DPM_HISTORY: {
            psm_time_t last_active_time = idle_period.start - prev_idle_period.end;
            psm_time_t last_idle_time = history[DPM_HIST_WIND_SIZE-1];

            psm_time_t t_idle_pred = hparams.alpha[0];                          //K0
            t_idle_pred += hparams.alpha[1]*last_idle_time;                     //K1 * T_idle[i-1]
            t_idle_pred += hparams.alpha[2]*(last_idle_time * last_idle_time);  //K2 * (T_idle[i-1]^2)
            t_idle_pred += hparams.alpha[3]*last_active_time;                   //K3 * T_active[i-1]
            t_idle_pred += hparams.alpha[4]*last_active_time*last_idle_time;    //K4 * t_active[i-1] * t_idle[i-1]
            t_idle_pred += hparams.alpha[5]*(last_active_time*last_active_time);//K5 * (t_active[i-1]^2)

            printf("Next prediction idle: %f\n", t_idle_pred);
            if (t_idle_pred > hparams.threshold[0])
                *next_state = PSM_STATE_SLEEP;
            else if (t_idle_pred > hparams.threshold[1])
                *next_state = PSM_STATE_IDLE;
            else
                *next_state = PSM_STATE_ACTIVE;
            break;}

        case DPM_LAST_ACTIVE:
            psm_time_t last_active_time = idle_period.start - prev_idle_period.end;
            if (last_active_time < laparams.threshold[0])
                *next_state = PSM_STATE_SLEEP;
            else if (last_active_time < laparams.threshold[1])
                *next_state = PSM_STATE_IDLE;
            else
                *next_state = PSM_STATE_ACTIVE;
            break;
        

        default:
            printf("[error] unsupported policy\n");
            return 0;
    }
	return 1;
}

/* initialize idle time history */
void dpm_init_history(psm_time_t *h)
{
	for (int i=0; i<DPM_HIST_WIND_SIZE; i++) {
		h[i] = 0;
	}
}

/* update idle time history */
void dpm_update_history(psm_time_t *h, psm_time_t new_idle)
{
	for (int i=0; i<DPM_HIST_WIND_SIZE-1; i++){
		h[i] = h[i+1];
	}
	h[DPM_HIST_WIND_SIZE-1] = new_idle;
}
