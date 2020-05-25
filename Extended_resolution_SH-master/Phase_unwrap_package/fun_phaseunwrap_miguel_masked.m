function [unwrapped_phase] = fun_phaseunwrap_miguel_masked(wrappedphase, mask)

unwrapped_phase = mxMiguel_2D_unwrapper_with_mask(single(wrappedphase),mask);
clear mxMiguel_2D_unwrapper_with_mask

end
