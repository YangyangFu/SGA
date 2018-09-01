function [opt,out,frontpop]=sorting(opt,combinepop)
% Function SORT: sort individuals based on given rank techniques.

sortingfun=opt.sortingfun{1,1};

switch sortingfun
    case 'nds'
        % Fast non dominated sort

        [opt, out,frontpop] = ndsort(opt, combinepop);
      
    case 'dis'
        % Deterministic infeasibility sort

        [opt,out,frontpop]=infeasort(opt,combinepop);

    otherwise
        error('sorting function does not exsit!');
end
end