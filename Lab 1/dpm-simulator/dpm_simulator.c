/**
 * @brief The main DPM simulator program
 */

#include "inc/psm.h"
#include "inc/dpm_policies.h"
#include "inc/utilities.h"

#define MAX_FILENAME 256

int main(int argc, char *argv[]) {

    char fwl[MAX_FILENAME];
    psm_t psm;
    dpm_timeout_params tparams;
    dpm_history_params hparams;
    dpm_last_active_params laparams;
    dpm_policy_t sel_policy;

    if(!parse_args(argc, argv, fwl, &psm, &sel_policy, &tparams, &hparams, &laparams)) {
        printf("[error] reading command line arguments\n");
        return -1;
    }
    psm_print(psm);
    //dpm_simulate(psm, sel_policy, tparams, hparams, laparams, fwl);
    //printf("\n");
	dpm_simulate_real(psm, sel_policy, tparams, hparams, laparams, fwl);

    return 0;
}
