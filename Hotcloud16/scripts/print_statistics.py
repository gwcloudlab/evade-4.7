#!/usr/bin/python

import sys
from numpy import mean

def parse(filename):

    suspend = 0
    libvmi_write = 0
    libvmi_read = 0
    dirtied_pages_started = 0
    dirtied_pages_finished = 0
    add_to_batch_started = 0
    add_to_batch_ended = 0
    flush_batch_ended = 0
    resume = 0

    w_a_started = 0
    w_b_started = 0
    w_c_started = 0
    w_d_started = 0
    w_e_started = 0
    w_f_started = 0

    suspend_libvmi_write = []
    suspend_libvmi_read = []
    suspend_resume = []
    suspend_dirtied_pages_started = []
    suspend_dirtied_pages_finished = []
    suspend_add_to_batch_started = []
    suspend_add_to_batch_finished = []
    suspend_flush_batch_finished = []
    dirty_page_count = []

    suspend_w_a_started = []
    suspend_w_b_started = []
    suspend_w_c_started = []
    suspend_w_d_started = []
    suspend_w_e_started = []
    suspend_w_f_started = []

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
            elif "add_to_batch started at" in line:
                add_to_batch_started = float(items[-2])
            elif "add_to_batch ended at" in line:
                add_to_batch_ended = float(items[-2])
            elif "write_batch_a started at" in line:
                w_a_started = float(items[-2])
            elif "write_batch_b started at" in line:
                w_b_started = float(items[-2])
            elif "write_batch_c started at" in line:
                w_c_started = float(items[-2])
            elif "write_batch_d started at" in line:
                w_d_started = float(items[-2])
            elif "write_batch_e started at" in line:
                w_e_started = float(items[-2])
            elif "write_batch_f started at" in line:
                w_f_started = float(items[-2])
            elif "flush_batch ended at" in line:
                flush_batch_ended = float(items[-2])
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
                suspend_add_to_batch_started.append(add_to_batch_started - suspend)
                suspend_w_a_started.append(w_a_started - suspend)
                suspend_w_b_started.append(w_b_started - suspend)
                suspend_w_c_started.append(w_c_started - suspend)
                suspend_w_d_started.append(w_d_started - suspend)
                suspend_w_e_started.append(w_e_started - suspend)
                suspend_w_f_started.append(w_f_started - suspend)
                suspend_add_to_batch_finished.append(add_to_batch_ended - suspend)
                suspend_flush_batch_finished.append(flush_batch_ended - suspend)
                suspend_libvmi_write.append(libvmi_write - suspend)
                suspend_libvmi_read.append(libvmi_read - suspend)
                suspend_resume.append(resume - suspend)

    print "Avg. statistics for this run:"
    print "Suspend to resume: ", str(mean(suspend_resume)*1000), " Milliseconds"
    print "Suspend to libvmi write: ", str(mean(suspend_libvmi_write)*1000), " Milliseconds"
    print "Suspend to libvmi read: ", str(mean(suspend_libvmi_read)*1000), " Milliseconds"
    print "Suspend to Dirty pages sending start: ", str(mean(suspend_dirtied_pages_started)*1000), " Milliseconds"
    print "Suspend to add_to_batch fn start: ", str(mean(suspend_add_to_batch_started)*1000), " Milliseconds"
    print "Suspend to add_to_batch fn end: ", str(mean(suspend_add_to_batch_finished)*1000), " Milliseconds"
    print "Suspend to w_a checkpoint start: ", str(mean(suspend_w_a_started)*1000), " Milliseconds"
    print "Suspend to w_b checkpoint start: ", str(mean(suspend_w_b_started)*1000), " Milliseconds"
    print "Suspend to w_c checkpoint start: ", str(mean(suspend_w_c_started)*1000), " Milliseconds"
    print "Suspend to w_d checkpoint start: ", str(mean(suspend_w_d_started)*1000), " Milliseconds"
    print "Suspend to w_e checkpoint start: ", str(mean(suspend_w_e_started)*1000), " Milliseconds"
    print "Suspend to w_f checkpoint start: ", str(mean(suspend_w_f_started)*1000), " Milliseconds"
    print "Suspend to flush_batch fn end: ", str(mean(suspend_flush_batch_finished)*1000), " Milliseconds"
    print "Suspend to Dirty pages sending end: ", str(mean(suspend_dirtied_pages_finished)*1000), " Milliseconds"
    print "Dirty page count: ", str(mean(dirty_page_count)), " Pages"

def main():
    parse(sys.argv[1])

if __name__ == '__main__':
    main()
