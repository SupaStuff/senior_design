%AMuse - Use a model by adding subdirectory to path
%
% The AMuse function adds a subdirectory containing files specific to 
% a given model to your current path.  This function is called at the top
% of various example files that use a common model or set of parameter
% definitions.
% 
% Usage: AMuse('model')

% RMM, 1 May 2010
function status = amuse(model_name, verbose)

% Set default arguments
if nargin < 2, verbose = 0; end

% Create the path to the initialization script
model_init = strcat(model_name, '_init');

% First check to see if the model is already in our path
if (exist(model_init) == 2)
  if (verbose) 
    fprintf(2, 'Model subdirectory %s is already in path\n', model_name);
  end;
  status = 1;

else
  % Find the location of the base installation
  amsetup_path = which('amsetup');
  [ampath, name, ext, versn] = fileparts(amsetup_path);

  % Construct the path to the model file and make sure it exists
  model_path = strcat(ampath, '/', model_name);
  if (exist(model_path) ~= 7) 
    % Generate an error message
    fprintf(2, 'Cannot find subdirectory for model %s\n', model_name);
    status = 0;

  else
    % Add the path to the model file to the path
    path(path, model_path);
    status = 1;

   % Let the user know, if verbose message are on
    if (verbose) 
      fprintf(2, 'Model subdirectory %s added to path\n', model_name);
    end

    % See if the initialization file is there
    if (exist(model_init) ~= 2) 
      if (verbose) 
        fprintf(2, 'Initialization file missing for mode %s\n', model_name);
      end

    else
      % Run the initialization script
      eval(model_init);
    end
  end
end
