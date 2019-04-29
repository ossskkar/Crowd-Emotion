% DESCRIPTION: Compute vocabulary (VOCAB) and Mean Distance Traveled per 
%              zone per for each pair of origin/destination motivation.

% Clean up
clear; close all; clc;
clc; disp('Step 8.1: Clean up'); 

% Load data
clc; disp('Step 8.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Use only training data 
%dataset = data.trainSet;

% For each training/test set
for set_i = 1:length(data.trainSet)
    dataset = data.trainSet{set_i};
    
    % Initialize variables
    list_origin_dest = [];
    sti = 1;

% Convert each track to subtracks and to words
for ti = 1:dataset.tracks_len

    disp(['Step 8.3: Processing track #' num2str(ti)]);

    % Get motivations groundtruth for track ti
    m = dataset.tracks_m_groundtruth{ti};

    % Ignore tracks that remain in the same motivation 
    if (length(unique(m)) > 1)

        % Get track data
        this_track = dataset.tracks{ti};
        [len_track, ~] = size(this_track);

        % Compute index of subtracks
        prev_m = m(1);
        cur_m = m(1);

        for mi = 1:length(m)

            % Initialize index of first subtrack 
            if mi == 1
                di = 1; 
            elseif (prev_m ~= cur_m) && ((cur_m ~= m(mi)) || (mi == length(m)))

                % Get final index of subtrack
                if mi ==  length(m)
                    df = length(m);
                else
                    df = mi-1;
                end

                % Add subtrack [time track_id x y]
                subtracks{sti}(:,1) =  dataset.tracks{ti}(di:df,1);
                subtracks{sti}(:,2) = ti;
                subtracks{sti}(:,3:4) = dataset.tracks{ti}(di:df,2:3);

                % Add word (clustered zones)
                words{sti} = net_cluster(TOPO.output.weight, subtracks{sti}(:,3:4));

                % Add subtrack to list 
                list_origin_dest = [list_origin_dest; find(ismember(POI.pairs, [prev_m m(mi-1)],'rows'))];

                % Update initial index of next subtrack
                di = df;

                % Update subtrack index
                sti = sti + 1;

                % Update previous motivation
                prev_m = cur_m;
            end

            % Update current motivation
            cur_m = m(mi);
        end
    end
end

% Create vocabulary for each pair
for pi = 1:POI.pairs_len

    disp(['Step 8.4: Processing pair #' num2str(pi)]);

    % Initialize vocabulary for pair pi
    pi_vocab = {};
    pi_vocab_count = [];
    wj = 1;

    % Get list of words for pair pi
    w_list = find(list_origin_dest == pi);

    % For each word in the list
    for wi = 1:length(w_list)

        % Get word wi
        new_word = words{w_list(wi)};

        % Reduce word to basic word
        new_word(diff(new_word)==0) = [];

        % If the vocabulary is empty
        if (wj == 1)

            % Add new word and update counter
            pi_vocab{wj} = new_word;
            pi_vocab_count = 1;

            % Update vocabulary index
            wj = wj + 1;

        % Check if the word is already in the vocabulary
        else
            w_exist = 0;
            % For each word in the vocabulary
            for wk = 1:wj-1

                % If the word already exist
                if length(new_word) == length(pi_vocab{wk})
                    if new_word == pi_vocab{wk}

                        % Flag word as existing
                        w_exist = 1;

                        % Update the word count
                        pi_vocab_count(wk) = pi_vocab_count(wk) + 1;

                        % Exit for loop
                        break;
                    end
                end
            end

            % If the word doesnt exist in the vocabulary
            if w_exist == 0

                % Add new word and update counter
                pi_vocab{wj} = new_word;
                pi_vocab_count = [pi_vocab_count; 1];

                % Update vocabulary index
                wj = wj + 1;
            end
        end
    end

    % Add new vocabulary to list 
    VOCAB.words{pi} = pi_vocab;
    VOCAB.words_count{pi} = pi_vocab_count;
end

% Compute mean distance traveled per zone per origin-destination pair

% For each subtrack
for sti = 1:length(subtracks)

    disp(strcat('Step 8.5:  Processing subtrack: ', num2str(sti)));

    % Get length of subtrack
    [sti_len, ~] = size(subtracks{sti});

    % There is no distance traveled in the first data sample
    subtracks{sti}(1,5) = 0;

    % For each data sample of subtrack sti
    for di = 2:sti_len

        % Compute euclidean distance between data point di and di-1
        subtracks{sti}(di,5) = ...
            sqrt((subtracks{sti}(di,3) - subtracks{sti}(di-1,3))^2 + ...
            (subtracks{sti}(di,4) - subtracks{sti}(di-1,4))^2);
    end
end

% Initialize array for mdt per zone per pair
POI.mean_dist_travel = zeros(POI.pairs_len, config.TOPO.params.n_neurons);

% For each pair
for pi = 1:POI.pairs_len

    disp(strcat('Step 8.6: Computing MDT for pair: ', num2str(pi)));

    % Intialize matrix to store mean distance traveled per zone
    mdt_perZone = zeros(config.TOPO.params.n_neurons, 2);

    pi_list = find(list_origin_dest == pi);

    % For each subtrack/word in the list of pair pi
    for sbi = 1:length(pi_list)

        % Get indexes of transition between zones for a subtrack
        [z, z_idx] = unique(words{pi_list(sbi)});
        temp = sortrows([z z_idx],2);
        z = temp(:,1);
        z_idx = temp(:,2);

        % For each zone crossed by subtrack sbi
        for zi = 1:length(z)

            % Sum the distance traveled
            if (zi < length(z))
                mdt_perZone(z(zi),1) = mdt_perZone(z(zi),1) + ...
                    sum(subtracks{pi_list(sbi)}(z_idx(zi):(z_idx(zi+1)-1),5));

                % Update the occurence counter 
                mdt_perZone(z(zi),2) = mdt_perZone(z(zi),2) + 1;
            else
                mdt_perZone(z(zi),1) = mdt_perZone(z(zi),1) + ...
                    sum(subtracks{pi_list(sbi)}(z_idx(zi):length(words{pi_list(sbi)}),5));

                % Update the occurence counter 
                mdt_perZone(z(zi),2) = mdt_perZone(z(zi),2) + 1;
            end
        end
    end

    % Compute final mean distance traveled per zone for pair pi
    POI.mean_dist_travel(pi,:) = mdt_perZone(:,1)./mdt_perZone(:,2);
    POI.mean_dist_travel(pi,isnan(POI.mean_dist_travel(pi,:)))=0;
end

% Save data
clc; disp('Step 8.7: Save data');
save(config.POIFile, 'POI');
save(config.VOCABFile, 'VOCAB');

% Clean on exit
clear; close all; clc;
clc; disp('Step 8: Done!');


