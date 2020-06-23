function coords = downloadCoords_UOulu(place)
        %DOWNLOADCOORDS downloads longitude/latitude coordinates for a place
        %   using the google geocoding API.
        %
        %   returns a struct with fields "minLon", "maxLon", "minLat", and
        %       "maxLat".

            baseurl = "https://nominatim.openstreetmap.org/search";
            place = urlencode(place);
            url = sprintf("%s?&city=%s&format=json", baseurl, place);
            data = jsondecode(urlread(url));
            if isstruct(data)
                bbox = data(1).boundingbox;
            elseif iscell(data)
                bbox = data{1}.boundingbox;
            elseif isempty(data)
                coords = 'Unknown place';
                        return; 
            end
            geometry = cellfun(@str2double, bbox);
            coords = struct("minLon", geometry(3), ...
                            "maxLon", geometry(4), ...
                            "minLat", geometry(1), ...
                            "maxLat", geometry(2));
            if coords.minLon > coords.maxLon
                [coords.minLon, coords.maxLon] = ...
                    deal(coords.maxLon, coords.minLon);
            end
            if coords.minLat > coords.maxLat
                [coords.minLat, coords.maxLat] = ...
                    deal(coords.maxLat, coords.minLat);
            end
        end