#include "inc/dpm_policies.h"

int dpm_simulate(psm_t psm, dpm_policy_t sel_policy, dpm_timeout_params
		tparams, dpm_history_params hparams, char* fwl)
{

	FILE *fp;
	psm_interval_t idle_period;
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

    // main loop
    while(fscanf(fp, "%lf%lf", &idle_period.start, &idle_period.end) == 2) {

        t_idle_ideal += psm_duration(idle_period);
		dpm_update_history(history, psm_duration(idle_period));

        // for each instant until the end of the current idle period
		for (; curr_time < idle_period.end; curr_time++) {

            // compute next state
            if(!dpm_decide_state(&curr_state, curr_time, idle_period, history,
                        sel_policy, tparams, hparams)) {
                printf("[error] cannot decide next state!\n");
                return 0;
            }

            if (curr_state != prev_state) {
                if(!psm_tran_allowed(psm, prev_state, curr_state)) {
                    printf("[error] prohibited transition!\n");
                    return 0;
                }
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

int dpm_decide_state(psm_state_t *next_state, psm_time_t curr_time,
        psm_interval_t idle_period, psm_time_t *history, dpm_policy_t policy,
        dpm_timeout_params tparams, dpm_history_params hparams)
{
    switch (policy) {

        case DPM_TIMEOUT:
            /* Day 2: EDIT */
            if(curr_time > idle_period.start + tparams.timeout) {
                *next_state = PSM_STATE_IDLE;
            } else {
                *next_state = PSM_STATE_ACTIVE;
            }
            break;

        case DPM_HISTORY:
            /* Day 3: EDIT */
            if(curr_time < idle_period.start) {
                *next_state = PSM_STATE_ACTIVE;
            } else {
                *next_state = PSM_STATE_ACTIVE;
            }
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
