% DESCRIPTION: Computes the prototype (ideal) tracks of a motivation (attractor),
%              given an initial position.
%
% INPUT:       y0 => Initial point 
%              attractors => list of attractors
% 
% OUTPUT:      proto_tracks => list of proto tracks given y0

function proto_tracks = get_proto_tracks(y0, attractors)

    % Initialize list of proto tracks
    proto_tracks = cell(length(attractors),1);

    % For each attractor 
    for ai = 1:length(attractors)

        % Initialize new prototype track
        new_proto = y0;
        n = 1;

        % If the track hasn't reach the attractor
        while (~any(ismember(round(new_proto(n,:)),attractors{ai}.p,'rows')))  

            %b Get current point in force field of attractor ai
            cp = round(new_proto(n,:));
                
            % Check if track is stuck in a loop or back-forward loop
            if ((n>1) && (sum(new_proto(n,:) - new_proto(n-1,:)) == 0)) || ...
                 ((n>2) && (sum(new_proto(n,:) - new_proto(n-2,:)) == 0))
                
                option = randi([1 2]);
                
                if (option == 1)
                    wcard_a = randi([1 2]);
                    wcard_c = randi([-10 10]);
                    wcard_b = randi([-10 10]);

                    % Randomly switch to a different point
                    %cp(wcard_a) = cp(wcard_a) + wcard_b;
                    cp(1) = cp(1) + wcard_b;
                    cp(2) = cp(2) + wcard_c;
                    
                else
                    
                end
            end
            
            % Check for zero values
            if (cp(1) <= 0); cp(1) = 1; end
            if (cp(2) <= 0); cp(2) = 1; end
            
            % Check for points bigger than size of the attractor matrix
            [att_n, att_m] = size(attractors{ai}.df_x);
            if (cp(1) > att_m) cp(1) = att_m; end
            if (cp(2) > att_n) cp(2) = att_n; end
            
            % Get (n+1) point 
            delta = [attractors{ai}.df_x(cp(2), cp(1)) attractors{ai}.df_y(cp(2), cp(1))];

            % Compute next possible points
            np1 = round(new_proto(n,:)+delta); % using (x,y) of delta
            if (np1(1) == 0); np1(1) = 1; end
            if (np1(2) == 0); np1(2) = 1; end
            
            np2 = round([new_proto(n,1)+delta(1), new_proto(n,2)]); % using only x of delta
            if (np2(1) == 0); np2(1) = 1; end
            if (np2(2) == 0); np2(2) = 1; end
            
            np3 = round([new_proto(n,1), new_proto(n,2)+delta(2)]); % using only y of delta
            if (np3(1) == 0); np3(1) = 1; end
            if (np3(2) == 0); np3(2) = 1; end
            
            % If next point 1 (np1) is nonzero or if reach attractor
            if (any([attractors{ai}.df_x(np1(2), np1(1)) attractors{ai}.df_y(np1(2), np1(1))]) ...
                    || any(ismember(np1,attractors{ai}.p,'rows')))
                new_proto = [new_proto; np1];
            % If next point 2 (np2) is nonzero or if reach attractor
            elseif (any([attractors{ai}.df_x(np2(2), np2(1)) attractors{ai}.df_y(np2(2), np2(1))]) ...
                    || any(ismember(np2,attractors{ai}.p,'rows')))
                new_proto = [new_proto; np2];
            % If next point 3 (np3) is nonzero or if reach attractor
            elseif (any([attractors{ai}.df_x(np3(2), np3(1)) attractors{ai}.df_y(np3(2), np3(1))]) ...
                    || any(ismember(np3,attractors{ai}.p,'rows')))
                new_proto = [new_proto; np3];
            else
                break;
            end

            % Update size of new_proto track
            n = n+1;
        end

        % Update list of proto tracks
        proto_tracks{ai} = new_proto; 
    end 
end