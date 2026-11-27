import { afterEach, describe, expect, it, vi } from 'vitest';
import { debounce } from './debounce';

afterEach(() => vi.useRealTimers());

describe('debounce', () => {
  it('waits for the full delay and uses only the latest arguments', () => {
    vi.useFakeTimers();
    const callback = vi.fn();
    const debounced = debounce(callback, 300);
    debounced('Alpha');
    vi.advanceTimersByTime(299);
    expect(callback).not.toHaveBeenCalled();
    debounced('Beta');
    vi.advanceTimersByTime(299);
    expect(callback).not.toHaveBeenCalled();
    vi.advanceTimersByTime(1);
    expect(callback).toHaveBeenCalledExactlyOnceWith('Beta');
  });

  it('cancels a pending callback and remains usable for later calls', () => {
    vi.useFakeTimers();
    const callback = vi.fn();
    const debounced = debounce(callback, 300);
    debounced('Alpha');
    debounced.cancel();
    vi.advanceTimersByTime(300);
    expect(callback).not.toHaveBeenCalled();
    debounced('Beta');
    vi.advanceTimersByTime(300);
    expect(callback).toHaveBeenCalledExactlyOnceWith('Beta');
    debounced.cancel();
    vi.advanceTimersByTime(300);
    expect(callback).toHaveBeenCalledTimes(1);
  });
});
