function merged = SAXSLee_SAXSWAXSmerge(data)

qs = data.colData(:,1);
Is = data.colData(:,2);
ss = data.colData(:,3);
qw = data.colWData(:,1);
Iw = data.colWData(:,2);
sw = data.colWData(:,3);
ind0 = Is == 0;
qs(ind0) = [];Is(ind0) = [];ss(ind0) = [];
ind0 = Is == 0;
qw(ind0) = [];Iw(ind0) = [];sw(ind0) = [];
qwmin = qw(3);
qsmax = qs(end-5);
merged = [];
if qsmax > qwmin
    inds = qs > qwmin;
    indw = qw < qsmax;
    %Iwint = interp1(qw(indw), Iw(indw), qs(inds));
    ratio = mean(Iw(indw))/mean(Is(inds));
    %ratio = Is(inds)\Iwint(:);
    Iw = Iw/ratio;
    fprintf('Normalization factor is %0.5f', ratio);
    indx = (qwmin+qsmax)/2;
    indaway = qs > indx;
    qs(indaway) = []; Is(indaway) = []; ss(indaway) = [];
    
    indaway = qw < indx;
    qw(indaway) = []; Iw(indaway) = []; sw(indaway) = [];
    
    %sres = qs(end) - qs(end-1);
    merged(:,1) = [qs;qw];
    merged(:,2) = [Is;Iw];
    merged(:,3) = [ss;sw];
else
    merged(:,1) = [qs;qw];
    merged(:,2) = [Is;Iw];
    merged(:,3) = [ss;sw];
end   
