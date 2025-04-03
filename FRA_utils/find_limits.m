
function [Span, Limits] = find_limits(ax_frame, ax)
    arguments
        ax_frame
        ax {mustBeMember(ax, ["x", "y"])} = "y"
    
    end
    
    lines = ax_frame.Children;
    Max = -inf;
    Min = +inf;
    for i = 1:numel(lines)
        if ax == "x"
            Line = lines(i).XData;
        else
            Line = lines(i).YData;
        end
        if max(Line) > Max
            Max = max(Line);
        end
        if min(Line) < Min 
            Min = min(Line);
        end
    end
    
    if numel(lines) == 0
        Span = [];
        Limits = [];
    else
        Span = Max - Min;
        Limits = [Min Max];
    end

end



