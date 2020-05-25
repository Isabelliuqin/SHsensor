%% phase unwrapping algorithms API
% define phase unwrap method : unwrap_flag
% LP - LightPipes
% DCT - Unweighted DCT least squares phase unwrapping, it will change the
% abosulte vaule of phase
% matlab - the unwrap from matlab
% Goldstein - Goldstein branch cut path following method
% Miguel - Miguel_2D_unwrapper

function [unwrappedphase] = fun_phaseunwrap(phase, unwrap_flag)
%% NAN problem
tmp = isnan(phase);
if sum(tmp(:))
    error('There are missing points in the slopes!')
    return
else
%     if fun_is_phasewrap(phase)      % is the phase wrapped    
        if isequal(unwrap_flag,'LP')
            unwrappedphase = LPPhaseUnwrap(1,phase);

        elseif isequal(unwrap_flag,'DCT')
            unwrappedphase = fun_unwrappingPhase(phase);

        elseif isequal(unwrap_flag,'matlab')
            unwrappedphase = unwrap(phase);

        elseif isequal(unwrap_flag,'Goldstein')
            unwrappedphase = fun_GoldsteinUnwrap(phase);

        elseif isequal(unwrap_flag,'Miguel')
            unwrappedphase = Miguel_2D_unwrapper(single(phase));

        elseif isequal(unwrap_flag,'None')
            unwrappedphase = phase;
        end
        
%     else
%         unwrappedphase = phase;     % phase is not wrapped
%     end
end
    
end
