#!/usr/bin/python
import pexpect
import os
import sys


def find_panic(cmd_output, child):
    fields = cmd_output.splitlines()
    for line in fields:
       if 'Goroutine' not in line:
           continue
       subfields = line.split(' ')
       goroutineno = subfields[3]
       print goroutineno

       cmd = 'goroutine '+goroutineno +'\n'
       child.sendline(cmd)
       child.expect('dlv')
       
       child.sendline('bt')          
       child.expect('dlv')

       print child.before


def main(args):
    print args
    cmd = '/home/kgunjikar/third_party/src/github.com/derekparker/delve/cmd/dlv/dlv attach  '
    child = pexpect.spawn(cmd)
    child.expect ('dlv')
    child.sendline ('goroutines\n')
    child.expect('dlv')

    find_panic(child.before, child)
     

if __name__ == "__main__":
    main(sys.argv[1:])

