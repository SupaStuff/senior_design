% amprint - print a figure if AMPRINT flag is set
function status = amprint(filename)
global AMPRINT_FLAG;

if (exist('AMPRINT_FLAG') ~= 1 || isempty(AMPRINT_FLAG))
  fprintf(1, 'Skipping printing of %s (AMPRINT_FLAG not set)\n', filename);
  status = 0;
  return  
end

if (~AMPRINT_FLAG) 
  fprintf(1, 'Skipping printing of %s (AMPRINT_FLAG = %d)\n', filename, ...
    AMPRINT_FLAG);
  status = 0;
  return
end

if ((AMPRINT_FLAG == 1) || (AMPRINT_FLAG == 3))
  % Generate the default version of the figure (color)
  fprintf(1, 'Printing %s\n', filename);
  print('-depsc2', filename);
end

if ((AMPRINT_FLAG == 2) || (AMPRINT_FLAG == 3))
  % Generate the print version of the figure (B&W)
  if exist('print', 'dir')  == 7
    printfile = strcat('print/', filename);
    fprintf(1, 'Printing %s\n', printfile);
    print('-deps2', printfile);
  end
end

return;
