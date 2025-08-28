function plot_freevolume_from_excel()
% Spatial free-volume maps for three alloys × three quench rates
% Panels are plane slices (default XZ) with robust color scaling.
% Modes:
%   - 'delta'  : plot ΔV_free = post - pre (requires post files / ids, best for diverging)
%   - 'zscore' : plot (Vpre - baseline)/sigma with adaptive far-field or robust median/MAD
%   - 'raw'    : plot raw Vpre with sequential colormap
%


%% ---------------- USER SETTINGS ----------------
% Files for the three alloys (CuZr, CuZrAl, CuZrAlTi)
preFiles  = {'CuZr_FV.xlsx','CuZrAl_FV.xlsx','CuZrAlTi_FV.xlsx'};
sheetNames = {'Sheet1','Sheet2','Sheet3'};
valueKeys = {'free_volume','free','vfree','voronoi','volume','v_free','voronoi_volume'};
plotMode  = 'raw';

% Orientation & slice
plane      = 'XZ';     % 'XZ','XY','YZ'  (main paper: 'XZ')
sliceFrac  = 0.40;     % slab thickness as fraction of box length along dropped axis
gridN      = 400;      % grid resolution (per axis)
smooth_px  = 0.3;      % Gaussian blur (pixels), 0 to disable

% Indentation geometry (for far-field baseline)
R_tip  = 30;   % Å
h_max  = 20;   % Å
far_k_list = [3.0 2.5 2.0 1.8 1.5 1.3 1.2 1.0];

% Color scaling
symPercentile = 95;     % symmetric limits ±p_sym for diverging (delta/zscore)
seqPercentile = [5 95]; % [low high] for raw (sequential)

% Palettes
divergingPalette = 'coolwarm';
sequentialPalette = 'parula';

% Titles & labels
rates    = [1e11, 1e13, 1e15];
alloyLbl = {'Binary (Cu–Zr)','Ternary (Cu–Zr–Al)','Quaternary (Cu–Zr–Al–Ti)'};
%% ------------------------------------------------

% Decide mode
if strcmpi(plotMode,'auto')
    if all(cellfun(@(s)~isempty(s), postFiles))
        plotMode = 'delta';
    else
        plotMode = 'zscore';
    end
end

% ---- load all datasets; track global bounds ----
D = cell(3,3);
xlimG=[inf,-inf]; ylimG=[inf,-inf]; zlimG=[inf,-inf];

for iA = 1:3
    for j = 1:3
        Tpre = readtable(preFiles{iA}, "Sheet", sheetNames{j});
        x = Tpre.(pickCol(Tpre,'x')); y = Tpre.(pickCol(Tpre,'y')); z = Tpre.(pickCol(Tpre,'z'));
        v = Tpre.(pickValCol(Tpre,valueKeys));
        m = isfinite(x)&isfinite(y)&isfinite(z)&isfinite(v);
        x=x(m); y=y(m); z=z(m); v=v(m);
        idpre = []; if hasCol(Tpre,'id'), idpre = Tpre.(pickCol(Tpre,'id')); idpre = idpre(m); end
        S = struct('x',x,'y',y,'z',z,'vpre',v,'vpost',[],'hasPost',false,'idpre',idpre,'idpost',[]);

        if strcmpi(plotMode,'delta') && ~isempty(postFiles{iA})
            try
                Tpost = readtable(postFiles{iA}, "Sheet", sheetNames{j});
                if hasCol(Tpost,'id') && ~isempty(idpre)
                    idq = Tpost.(pickCol(Tpost,'id'));
                    Vq  = Tpost.(pickValCol(Tpost,valueKeys));
                    Mq = isfinite(idq)&isfinite(Vq);
                    Mp = isfinite(idpre);
                    [~, ia, ib] = intersect(double(idpre(Mp)), double(idq(Mq)));
                    if ~isempty(ia)
                        S.x = x(Mp); S.y = y(Mp); S.z = z(Mp); S.vpre = v(Mp); S.idpre = idpre(Mp);
                        S.x = S.x(ia); S.y = S.y(ia); S.z = S.z(ia); S.vpre = S.vpre(ia); S.idpre = S.idpre(ia);
                        S.vpost = Vq(Mq); S.vpost = S.vpost(ib);
                        S.idpost = idq(Mq); S.idpost = S.idpost(ib);
                        S.hasPost = true;
                    end
                else
                    Xq = Tpost.(pickCol(Tpost,'x')); Yq = Tpost.(pickCol(Tpost,'y')); Zq = Tpost.(pickCol(Tpost,'z'));
                    Vq = Tpost.(pickValCol(Tpost,valueKeys));
                    Mq = isfinite(Xq)&isfinite(Yq)&isfinite(Zq)&isfinite(Vq);
                    Fpre = scatteredInterpolant(x,y,z,v,'natural','nearest');
                    S.x = Xq(Mq); S.y = Yq(Mq); S.z = Zq(Mq); S.vpre = Fpre(S.x,S.y,S.z); S.vpost = Vq(Mq);
                    S.hasPost = true;
                end
            catch
                S.hasPost = false;
            end
        end

        D{iA,j} = S;
        xlimG = [min(xlimG(1),min(S.x)) max(xlimG(2),max(S.x))];
        ylimG = [min(ylimG(1),min(S.y)) max(ylimG(2),max(S.y))];
        zlimG = [min(zlimG(1),min(S.z)) max(zlimG(2),max(S.z))];
    end
end
cx = mean(xlimG); cy = mean(ylimG); cz = mean(zlimG);
Lx = diff(xlimG); Ly = diff(ylimG); Lz = diff(zlimG);
a_contact = sqrt(max(0, 2*R_tip*h_max - h_max^2));

% build common grid
switch upper(plane)
    case 'XZ'
        xi = linspace(xlimG(1),xlimG(2),gridN);
        zi = linspace(zlimG(1),zlimG(2),gridN);
        [XI,ZI] = meshgrid(xi,zi);
    case 'XY'
        xi = linspace(xlimG(1),xlimG(2),gridN);
        yi = linspace(ylimG(1),ylimG(2),gridN);
        [XI,ZI] = meshgrid(xi,yi); % ZI used as Y here
    case 'YZ'
        yi = linspace(ylimG(1),ylimG(2),gridN);
        zi = linspace(zlimG(1),zlimG(2),gridN);
        [XI,ZI] = meshgrid(yi,zi); % XI=Y, ZI=Z
    otherwise
        error('plane must be XZ, XY, or YZ');
end

% compute panel fields
valsAll = [];
maps = cell(3,3);
labelForCB = '';

for iA = 1:3
    for j = 1:3
        S = D{iA,j};

        % slice mask
        switch upper(plane)
            case 'XZ',   half = 0.5*sliceFrac*Ly; in = S.y>=cy-half & S.y<=cy+half;
            case 'XY',   half = 0.5*sliceFrac*Lz; in = S.z>=cz-half & S.z<=cz+half;
            case 'YZ',   half = 0.5*sliceFrac*Lx; in = S.x>=cx-half & S.x<=cx+half;
        end

        % choose value
        modeNow = plotMode;
        if strcmpi(plotMode,'delta') && ~S.hasPost
            warning('No usable POST for %s sheet %s → using z-score mode.', alloyLbl{iA}, sheetNames{j});
            modeNow = 'zscore';
        end

        switch lower(modeNow)
            case 'delta'
                val = S.vpost - S.vpre;
                labelForCB = '\DeltaV_{free} (Å^3)';
                isDiverging = true;
            case 'zscore'
                [mu, sg, rule] = chooseBaseline(S, cx, cy, a_contact, far_k_list);
                val = (S.vpre - mu) ./ max(sg,eps);
                labelForCB = sprintf('z(V_{free}) — %s', rule);
                isDiverging = true;
            case 'raw'
                val = S.vpre;
                labelForCB = 'V_{free} (Å^3)';
                isDiverging = false;
            otherwise
                error('Unknown plotMode: %s', plotMode);
        end

        % interpolate onto grid
        switch upper(plane)
            case 'XZ'
                F = scatteredInterpolant(S.x(in),S.z(in),val(in),'natural','nearest');
                V = F(XI,ZI);
            case 'XY'
                F = scatteredInterpolant(S.x(in),S.y(in),val(in),'natural','nearest');
                V = F(XI,ZI);
            case 'YZ'
                F = scatteredInterpolant(S.y(in),S.z(in),val(in),'natural','nearest');
                V = F(XI,ZI);
        end
        if smooth_px>0, V = gaussBlur2D(V, smooth_px); end
        maps{iA,j} = V;
        valsAll = [valsAll; V(:)]; %#ok<AGROW>
    end
end

% color limits
if any(strcmpi(plotMode,{'delta','zscore'}))
    absv = abs(valsAll(isfinite(valsAll)));
    if isempty(absv), v = 1; else, v = prctile(absv, symPercentile); end
    clims = [-v, +v];
    palette = divergingPalette;
else
    v1 = prctile(valsAll, seqPercentile(1));
    v2 = prctile(valsAll, seqPercentile(2));
    if ~isfinite(v1) || ~isfinite(v2) || v1==v2
        v1 = min(valsAll); v2 = max(valsAll);
    end
    clims = [v1, v2];
    palette = sequentialPalette;
end

% plot 3×3
f = figure('Color','w','Position',[100 100 1320 1000]);
tiledlayout(3,3,'Padding','compact','TileSpacing','compact');

for iA = 1:3
    for j = 1:3
        nexttile
        imagesc(maps{iA,j}); set(gca,'YDir','normal'); axis image
        switch lower(palette)
            case 'coolwarm', colormap(coolwarm(256));
            case 'parula',   colormap(parula(256));
            case 'turbo',    colormap(turbo(256));
            otherwise,       colormap(parula(256));
        end
        caxis(clims);
        switch upper(plane)
            case 'XZ', xlabel('x (Å)'); ylabel('z (Å)');
            case 'XY', xlabel('x (Å)'); ylabel('y (Å)');
            case 'YZ', xlabel('y (Å)'); ylabel('z (Å)');
        end
        title(sprintf('%s | q = 10^{%d} K s^{-1}', alloyLbl{iA}, round(log10(rates(j)))), ...
              'FontWeight','normal')
        set(gca,'LineWidth',1,'FontSize',10)
        if iA==1 && j==3
            cb = colorbar; cb.Label.String = labelForCB; cb.Box='off';
        end
    end
end

outfile = sprintf('FreeVolume_%s_3x3_%s.png', upper(plane), lower(palette));
print(gcf, outfile, '-dpng','-r300');
fprintf('Saved: %s\n', outfile);

end % main

%% ----------------- helpers -----------------
function name = pickCol(T, prefer)
names = T.Properties.VariableNames; low = lower(names);
p = lower(prefer);
idx = find(strcmp(low,p),1);
if ~isempty(idx), name = names{idx}; return; end
idx = find(contains(low,p),1);
if ~isempty(idx), name = names{idx}; return; end
error('Column "%s" not found. Available: %s', prefer, strjoin(names, ', '));
end

function name = pickValCol(T, keys)
names = T.Properties.VariableNames; low = lower(names);
for k = 1:numel(keys)
    hit = find(contains(low, lower(keys{k})),1);
    if ~isempty(hit), name = names{hit}; return; end
end
error('Could not find a free-volume column by keys: %s', strjoin(keys,', '));
end

function tf = hasCol(T, prefer)
tf = any(strcmpi(T.Properties.VariableNames, prefer)) || ...
     any(contains(lower(T.Properties.VariableNames), lower(prefer)));
end

function M = gaussBlur2D(M, sigma)
if sigma<=0, return; end
sz = max(3, round(6*sigma)); if mod(sz,2)==0, sz=sz+1; end
x = linspace(-((sz-1)/2), ((sz-1)/2), sz);
g = exp(-0.5*(x/sigma).^2); g = g/sum(g);
M = conv2(conv2(M,g,'same'), g','same');
end

function [mu, sg, rule] = chooseBaseline(S, cx, cy, a_contact, klist)
rr = hypot(S.x - cx, S.y - cy);
mu = NaN; sg = NaN; rule = '';
for k = klist
    far = rr > k * a_contact;
    ref = S.vpre(far);
    if nnz(isfinite(ref)) >= 0.10 * numel(S.vpre)
        mu = mean(ref,'omitnan');
        sg = std(ref,'omitnan');
        rule = sprintf('far-field (k=%.1f)', k);
        break
    end
end
if ~isfinite(mu) || ~isfinite(sg) || sg == 0
    med = median(S.vpre,'omitnan');
    mad = 1.4826 * median(abs(S.vpre - med),'omitnan');
    mu = med;
    sg = max(mad, eps);
    rule = 'global robust (median/MAD)';
end
end

function cmap = coolwarm(n)
% Smooth diverging colormap (blue-white-red). n×3 in [0,1].
if nargin<1, n=256; end
anchors = [...
    0.230, 0.299, 0.754;   % deep blue
    0.472, 0.621, 0.871;   % blue
    0.780, 0.914, 0.973;   % light cyan
    0.968, 0.968, 0.968;   % near white (center)
    0.992, 0.839, 0.733;   % light orange
    0.875, 0.512, 0.318;   % orange
    0.706, 0.016, 0.150];  % deep red
t0 = linspace(0,1,size(anchors,1))';
t  = linspace(0,1,n)';
cmap = [interp1(t0,anchors(:,1),t,'pchip'), ...
        interp1(t0,anchors(:,2),t,'pchip'), ...
        interp1(t0,anchors(:,3),t,'pchip')];
cmap = max(0,min(1,cmap));
end