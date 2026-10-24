export function changedText<K extends string>(
  before: Partial<Record<K, string | null>>,
  after: Record<K, string>,
  keys: readonly K[],
  required: readonly K[],
  requiredMessage: string,
): { patch: Partial<Record<K, string | null>>; message: string | null } {
  const requiredKeys = new Set<string>(required);
  for (const key of required) {
    if (after[key].trim() === "") {
      return { patch: {}, message: requiredMessage };
    }
  }

  const patch: Partial<Record<K, string | null>> = {};
  for (const key of keys) {
    const next = after[key].trim();
    const prev = (before[key] ?? "").trim();
    if (next === prev) continue;
    patch[key] = requiredKeys.has(key) ? next : next || null;
  }
  return { patch, message: null };
}
