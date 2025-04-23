
function wait_user_input(MSG)

stable = false;
while ~stable
    disp('----------------')
    disp(MSG)
    in = input('Proceed?(y/n) ', 's');
    if in == "y"
        stable = true;
    elseif in == "n"
        error('program closed by user');
    end
end

end