/// Simple debouncer for search inputs and other rapid-fire events.
export class Debouncer {
  private timeoutId: ReturnType<typeof setTimeout> | null = null;
  private delay: number;

  constructor(delay: number = 300) {
    this.delay = delay;
  }

  debounce(callback: () => void): void {
    if (this.timeoutId !== null) {
      clearTimeout(this.timeoutId);
    }
    this.timeoutId = setTimeout(() => {
      callback();
      this.timeoutId = null;
    }, this.delay);
  }

  cancel(): void {
    if (this.timeoutId !== null) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}
