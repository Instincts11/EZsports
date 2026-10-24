import { clearToken, getToken } from "@/lib/session";

const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "";

export class ApiError extends Error {
  status: number;

  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

function messageFrom(body: unknown): string {
  if (!body || typeof body !== "object" || !("detail" in body)) {
    return "The request failed.";
  }
  const detail = (body as { detail: unknown }).detail;
  if (typeof detail === "string" && detail.trim()) return detail;
  if (Array.isArray(detail)) {
    const parts = detail.map((item) => {
      if (item && typeof item === "object" && "msg" in item) {
        return String((item as { msg: unknown }).msg);
      }
      return "";
    });
    const text = parts.filter(Boolean).join(" ");
    if (text) return text;
  }
  return "The request failed.";
}

export async function api<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers);
  if (!headers.has("Content-Type") && options.body) {
    headers.set("Content-Type", "application/json");
  }
  const token = getToken();
  if (token) headers.set("Authorization", `Bearer ${token}`);

  let response: Response;
  try {
    response = await fetch(`${apiBase}/api/v1${path}`, {
      ...options,
      headers,
    });
  } catch {
    throw new ApiError("The academy API is not reachable.", 0);
  }

  if (response.status === 401) {
    clearToken();
  }

  if (!response.ok) {
    let message = "The request failed.";
    try {
      message = messageFrom(await response.json());
    } catch {
      message = response.statusText || message;
    }
    throw new ApiError(message, response.status);
  }

  if (response.status === 204) return undefined as T;
  return (await response.json()) as T;
}
