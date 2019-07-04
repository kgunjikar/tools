import os
  2
  3 REPLACE="\n    defer G(O(\"$FN(%d)\", i))\n"
  4
  5 def append_string_in_file(filename):
  6     try:
  7         print filename
  8         fd = open(filename,"r")
  9     except:
 10         print 'Unable to open file', filename
 11         return
 12     all_lines = fd.readlines()
 13     fd.close()
 14     print all_lines
 15
 16     fd = open(filename,"w")
 17     for line in all_lines:
 18         if 'func' in line and '{' in line and line.startswith('func'):
 19             appended_line = line + REPLACE
 20             print appended_line
 21             fd.write(appended_line)
 22         else:
 23             print line
 24             fd.write(line)
 25
 26 shpfiles = []
 27 for dirpath, subdirs, files in os.walk("."):
 28     for x in files:
 29         if x.endswith(".go"):
 30             shpfiles.append(os.path.join(dirpath, x))
 31
 32 for file in shpfiles:
 33     append_string_in_file(file)
~