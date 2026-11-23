/** Default debounce delay for keystroke-driven inputs. */
export const FILTER_DEBOUNCE_MS = 300;

/**
 * Creates a debounced version of `fn`. Each call resets the internal timer;
 * `fn` runs only after the timer expires without being reset. `cancel` discards
 * pending work without invoking it.
 */
export function debounce<TArgs extends unknown[]>(
	fn: (...args: TArgs) => void,
	ms: number,
): ((...args: TArgs) => void) & { cancel: () => void } {
	let timer: ReturnType<typeof setTimeout> | undefined;
	const debounced = (...args: TArgs) => {
		clearTimeout(timer);
		timer = setTimeout(() => {
			timer = undefined;
			fn(...args);
		}, ms);
	};
	debounced.cancel = () => {
		clearTimeout(timer);
		timer = undefined;
	};
	return debounced;
}
