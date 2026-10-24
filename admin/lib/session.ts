const tokenKey = "ezsports.admin.token";

export function getToken(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(tokenKey);
}

export function setToken(token: string): void {
  sessionStorage.setItem(tokenKey, token);
  window.dispatchEvent(new Event("ezsports-session"));
}

export function clearToken(): void {
  sessionStorage.removeItem(tokenKey);
  window.dispatchEvent(new Event("ezsports-session"));
}
