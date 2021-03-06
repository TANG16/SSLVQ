classdef HeurFORLVQ1UpdateRule < UpdateRule
    
    methods (Static = true)
        
        function Mod = update(Algo, Mod, Data, iData, varargin)
            
            % Use the auxiliary (Hellinger?) distances as a
            % heuristic...
            if isnan(Mod.AuxDists(1)) || isnan(Mod.AuxDistStats.mean())
                
                return;
                
            elseif Mod.AuxDists(1) < Mod.AuxDistStats.mean() % - Mod.AuxDistStats.std()
                                
                % Update the learning rate for the winning node...
                Mod.Alphas(Mod.BMUs(1)) = Mod.Alphas(Mod.BMUs(1)) / (1 + Mod.Alphas(Mod.BMUs(1)));

                % Update the BMU codebook vector (LVQ)...
                Mod.SOM.codebook(Mod.BMUs(1),Mod.known) =...
                    Mod.SOM.codebook(Mod.BMUs(1),Mod.known) +...
                        ((1 - Mod.AuxDists(1)) * Mod.Alphas(Mod.BMUs(1)) *...
                         (Mod.x(Mod.known) - Mod.SOM.codebook(Mod.BMUs(1),Mod.known)));

                % Update the feature weights (RLVQ)...
                TempMask = max(Mod.SOM.mask - (Mod.a_f * abs(Mod.Dx(Mod.BMUs(1),:)))', Mod.ZeroMask);
                TempMask = TempMask ./ norm(TempMask,1);
                Mod.SOM.mask(~isnan(TempMask)) = TempMask(~isnan(TempMask));
                
                % If the BMU classified the sample correctly, increment its
                % score...
                Mod.AccuracyHist(Mod.BMUs(1)) = Mod.AccuracyHist(Mod.BMUs(1)) + 1;
                
                % Record running stats of correctly classified samples for
                % each node...
                Mod.NodeStats{Mod.BMUs(1)}.push(Mod.x);

            else % if Mod.AuxDists(1) > Mod.AuxDistStats.mean() + Mod.AuxDistStats.std()
                % Update the learning rate for the winning node...
                Mod.Alphas(Mod.BMUs(1)) = min(Mod.Alphas(Mod.BMUs(1)) / (1 - Mod.Alphas(Mod.BMUs(1))), 1);

                % Update the BMU codebook vector (LVQ)...
                Mod.SOM.codebook(Mod.BMUs(1),Mod.known) =...
                    Mod.SOM.codebook(Mod.BMUs(1),Mod.known) -...
                        ((Mod.AuxDists(1) - 1) * Mod.Alphas(Mod.BMUs(1)) *...
                         (Mod.x(Mod.known) - Mod.SOM.codebook(Mod.BMUs(1),Mod.known)));

                % Update the feature weights (RLVQ)...
                Mod.SOM.mask = Mod.SOM.mask + (Mod.a_f * abs(Mod.Dx(Mod.BMUs(1),:)))';
                Mod.SOM.mask = Mod.SOM.mask ./ norm(Mod.SOM.mask,1);

            end
            
        end
        
    end
    
end
