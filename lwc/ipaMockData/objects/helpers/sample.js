export const sample = (arr, n) => {
    let size = n === undefined ? 1 : n;
    if (arr.length < size) return arr.slice();
    let result = [];
    while (result.length < size) {
        result.push(arr.splice(Math.floor(Math.random() * arr.length), 1)[0]);
    }
    return n ? result : result[0];
};

// maintains order by default (use sorted 'false' to randomize order)
export const sampleRandom = (arr, min, max, sorted = true) => {
    let minSize = min === undefined ? 1 : min,
        maxSize = max === undefined ? arr.length : max;
    let n = Math.floor(Math.random() * (maxSize + 1 - minSize)) + minSize;
    if (n === 0) return [];
    if (!sorted) return sample(arr, n);
    let ids = sample([...Array(arr.length).keys()], n).sort();
    let result = [];
    while (ids.length) {
        result.push(arr[ids.splice(0, 1)[0]]);
    }
    return result;
};