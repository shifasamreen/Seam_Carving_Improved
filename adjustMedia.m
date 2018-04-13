function adjusted_media = adjustMedia(media, target_size, type)

if strcmp(type, 'image')
    n = size(media,1);
    m = size(media,2);
    
    if n > target_size(1) && m > target_size(2)
        adjusted_media = imresize(media, [target_size(1), target_size(2)]);
    elseif n > target_size(1)
        adjusted_media = imresize(media, [target_size(1), m]);
    elseif m > target_size(2)
        adjusted_media = imresize(media, [n, target_size(2)]);
    else
        adjusted_media = media;
    end
else
    n = size(media(1).cdata,1);
    m = size(media(1).cdata,2);
    
    t_n = 0;
    t_m = 0;
    if n > target_size(1) && m > target_size(2)
        t_n = target_size(1);
        t_m = target_size(2);
    elseif n > target_size(1)
        t_n = target_size(1);
        t_m = m;
    elseif m > target_size(2)
        t_n = n;
        t_m = target_size(2);
    else
        t_n = n;
        t_m = m;
    end
    
    vframes = media;
    for i=1:length(vframes)
        vframes(i).cdata = imresize(vframes(i).cdata, [t_n,t_m]);
    end
    
    %select 30 frames only
    fi = round(linspace(1, length(vframes), 30));
    fi = unique(fi);
    adjusted_media = vframes(fi);
end