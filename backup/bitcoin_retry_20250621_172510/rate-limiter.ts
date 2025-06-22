/** Simple in-memory rate limiter (Template) */
export class RateLimiter {
  private requests: number[] = []
  constructor(private limit: number, private windowMs: number) {}
  isAllowed() {
    const now = Date.now()
    this.requests = this.requests.filter(t => now - t < this.windowMs)
    if (this.requests.length < this.limit) {
      this.requests.push(now)
      return true
    }
    return false
  }
}