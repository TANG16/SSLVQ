classdef SRNGUpdateRule < UpdateRule
    
    methods (Static = true)
        
        function Mod = update(Algo, Mod, Data, iData, varargin)

            %% GLVQ (Generalized Learning Vector Quantization) update...
            
%             % Grab w_J, the best matching node of the correct class...
%             CorrectClassBMULogicalIndices = Mod.ClassLabels(Mod.BMUs) == find(Data.ClassLabels(Data.GroundTruthLabelIndices, iData));
%             CorrectClassBMUIndices = find(CorrectClassBMULogicalIndices);
%             w_J = Mod.BMUs(CorrectClassBMUIndices(1));
%             
%             % Grab w_K, the next closest node of an incorrect class...
%             IncorrectClassBMUIndices = find(~CorrectClassBMULogicalIndices);
%             w_K = Mod.BMUs(IncorrectClassBMUIndices(1));
%             
%             D_J = (Mod.x(Mod.known) - Mod.SOM.codebook(w_J, Mod.known));
%             D_K = (Mod.x(Mod.known) - Mod.SOM.codebook(w_K, Mod.known));
%             
%             % Calculate the distance d_J of x (the sample) to w_J...
%             d_J = Mod.metric_withmask(D_J, Mod.SOM.mask);
%             
%             % Calculate the distance d_K of x (the sample) to w_K...
%             d_K = Mod.metric_withmask(D_K, Mod.SOM.mask);
%             
%             % Calculate the mu(x) part of the GLVQ update...
%             mu_x = (d_J - d_K) / (d_J + d_K);
%             
%             % Calculate the f(mu,t) sigmoidal function part of the GLVQ
%             % update...
%             % f_mu_t = 1 / (1 + exp(-mu_x * Algo.UpdaterPhases{Algo.currentphase}.t));
%             f_mu_t = 1 / (1 + exp(-10 * mu_x));
%             
%             % Estimate its derivative...
%             d_f_d_mu = 10 * f_mu_t * (1 - f_mu_t);
%             
%             % d_f_d_mu = exp(-mu_x) / ((1 + exp(-mu_x))^2);
%             
%             % Update w_J...            
%             Mod.SOM.codebook(w_J, Mod.known) =...
%                 Mod.SOM.codebook(w_J, Mod.known) +...
%                     (((4.0 * Mod.a * d_f_d_mu * d_K) / (d_J + d_K)) * (Mod.SOM.mask' .* D_J));
%                 
%             % Update w_K...
%             Mod.SOM.codebook(w_K, Mod.known) =... 
%                 Mod.SOM.codebook(w_K, Mod.known) -...
%                     (((4.0 * Mod.a * d_f_d_mu * d_J) / (d_J + d_K)) * (Mod.SOM.mask' .* D_K));                                
%                 
%             % Update the feature weights (GRLVQ)...            
%             Mod.SOM.mask = max(Mod.SOM.mask - (2.0 * Mod.a_f * d_f_d_mu *...
%                                                (((d_K * D_J.^2) - ((d_J * D_K.^2))) / (d_J + d_K)))',...
%                                Mod.ZeroMask);
%             Mod.SOM.mask = Mod.SOM.mask ./ norm(Mod.SOM.mask,1);

%             [yproto_est , Wproto_est , lambda_est ,  E_SRNG] =...
%                 srng_model(Xtrain(:,2) , ytrain(:,2) , options , yproto , Wproto , lambda);

%             options.epsilonk                   = 0.005;
%             options.epsilonl                   = 0.001;
%             options.epsilonlambda              = 10e-8;
%             options.sigmastart                 = 2;
%             options.sigmaend                   = 10e-4;
%             options.sigmastretch               = 10e-3;
%             options.threshold                  = 10e-10;
%             options.xi                         = 2;
%             options.nb_iterations              = 5000;
%             options.metric_method              = 1;
%             options.shuffle                    = 1;
%             options.updatelambda               = 1;

            options.epsilonk                   = Mod.a;
            options.epsilonl                   = Mod.a / 5;
            options.epsilonlambda              = min(Mod.a_f, options.epsilonl / 10);
            options.sigmastart                 = 2;
            options.sigmaend                   = 10e-4;
            options.sigmastretch               = 10e-3;
            options.threshold                  = 10e-10;
            options.xi                         = 2;
            options.nb_iterations              = 1;
            options.metric_method              = 1;
            options.shuffle                    = 0;
            options.updatelambda               = 1;
            
            x = Mod.x';
            y = find(Data.ClassLabels(Data.GroundTruthLabelIndices, iData));
            yproto = Mod.ClassLabels';
            wproto = Mod.SOM.codebook';
            lambda = Mod.SOM.mask;
            
            [yproto, wproto, lambda,  E_SRNG] =...
                srng_model(x, y, options, yproto, wproto, lambda);
            
            Mod.SOM.codebook = wproto';
            Mod.ClassLabels = yproto'; 
            Mod.SOM.mask = lambda;            
            
        end
        
    end
    
end