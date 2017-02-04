#!/usr/bin/python

import sys
from numpy import mean

def parse(filename):

    suspend = 0
    libvmi_write = 0
    dirtied_pages_started = 0
    dirtied_pages_finished = 0
    libvmi_read = 0
    resume = 0
    suspend_libvmi_write = []
    suspend_libvmi_read = []
    suspend_resume = []
    suspend_dirtied_pages_started = []
    suspend_dirtied_pages_finished = []
    dirty_page_count = []

    with open(filename, 'rb') as f:
        for line in f:
            # Skip data from live migration part
            if "starting checkpointing mechanism" in line:
                break
        for line in f:
            items = line.split(' ')
            if "Domain was suspending" in line:
                suspend = float(items[-2])
            elif "dirtied_pages started at" in line:
                dirtied_pages_started = float(items[-2])
            elif "dirtied_pages finished at" in line:
                dirtied_pages_finished = float(items[-2])
            elif "Writing to LibVMI" in line:
                libvmi_write = float(items[-2])
            elif "Reading from LibVMI at" in line:
                libvmi_read = float(items[-2])
            elif "Dirty page count" in line:
                dirty_page_count.append(float(items[-1]))
            elif "Domain was resumed" in line:
                resume = float(items[-2])
                suspend_dirtied_pages_started.append(dirtied_pages_started - suspend)
                suspend_dirtied_pages_finished.append(dirtied_pages_finished - suspend)
                suspend_libvmi_write.append(libvmi_write - suspend)
                suspend_libvmi_read.append(libvmi_read - suspend)
                suspend_resume.append(resume - suspend)

    print "Avg. statistics for this run:"
    print "Suspend to resume: ", str(mean(suspend_resume)*1000), " Milliseconds"
    print "Suspend to Dirty pages sending start: ", str(mean(suspend_dirtied_pages_started)*1000), " Milliseconds"
    print "Suspend to Dirty pages sending end: ", str(mean(suspend_dirtied_pages_finished)*1000), " Milliseconds"
    print "Suspend to libvmi write: ", str(mean(suspend_libvmi_write)*1000), " Milliseconds"
    print "Suspend to libvmi read: ", str(mean(suspend_libvmi_read)*1000), " Milliseconds"
    print "Dirty page count: ", str(mean(dirty_page_count)), " Pages"

def main():
    parse(sys.argv[1])

if __name__ == '__main__':
    main()
