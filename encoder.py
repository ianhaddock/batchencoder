import subprocess
import sys


#Define correct use
def usage():
    print "Usage: -n NAME"
    print ""
    print "Count number of processes for a given name"
    print ""
    print "-n NAME   Name of the process filtered"

def count_processes():
    count = 0
    name = sys.argv[2]
    output = subprocess.check_output(["ps","aux"])
    for line in output.split("/n"):
        if name in line:
            print line
            count += 1

    print "Number of matches: " + str(count)

if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] != "-n":
        usage()
    else: 
        count_processes()



