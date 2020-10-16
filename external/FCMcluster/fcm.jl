using Clustering
using StatsBase
using Plots

# make a random dataset with 1000 points, each point is a 5-dimensional vector
X = rand(100, 1000)
# X is translate first

begin
    # performs Fuzzy C-means over X, trying to group them into 3 clusters
    # with a fuzziness factor of 2. Set maximum number of iterations to 200
    # set display to :iter, so it shows progressive info at each iteration
    R = fuzzy_cmeans(X, 3, 2, maxiter=200, display=:iter)

    # get the centers (i.e. weighted mean vectors)
    # M is a 5x3 matrix
    # M[:, k] is the center of the k-th cluster
    M = R.centers'
    # get the point memberships over all the clusters
    # memberships is a 20x3 matrix
    memberships = R.weights

    nc = 3
    N = 1000
    ids = zeros(Int, N)
    for i = 1:N
        ids[i] = findmax(memberships[i, :])[2]
    end
    countmap(ids)
    # 384, 255,    
end

## performance index


