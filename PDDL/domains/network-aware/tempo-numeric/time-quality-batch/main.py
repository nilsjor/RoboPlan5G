import re
import subprocess

headings = "METRIC_VALUE; Solution number; Total time; Search time; Actions; Duration; Plan quality; Total Num Flips"

for prb_max in [32,16,12,10,8]:

    best_cost = 999
    best_plan = ''

    print("---")
    print("PRB constraints = %d" % prb_max)
    print("---")

    print(headings)

    subprocess.run("sed -i 's/(prbs-max) [0-9]*/(prbs-max) %d/g' ../problem.pddl" % prb_max, shell=True)

    for x in range(0,prb_max*4):

        out = subprocess.check_output("~/.planutils/bin/lpg-td ../domain.pddl ../problem.pddl -n 1", shell=True).decode("utf-8")
        trim = out.split('\n')[-10:-2]

        # Save planning metrics (time, quality, duration, etc.)
        new = []
        for val in trim:
            num = re.sub('.*[:=]\s*(\d+\.?\d*)\s*','\\1', val)
            new.append(num)
            if ('METRIC_VALUE' in val) and (float(num) < best_cost):
                best_plan = out
                best_cost = float(num)

        print('; '.join(new))

    # Save best plan
    with open('tn-%.0f-%d.plan' % (best_cost, prb_max), 'w') as f: f.write(best_plan)