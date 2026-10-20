# Project instructions

- For every update, keep all new and changed user-facing text synchronized in Turkish (`tr`), English (`en`), and Dutch (`nl`). This includes screens, buttons, dialogs, About content, and release notes. Do not ship untranslated UI strings.
- Update the release notes and increment the application build number for each update delivered to the phone. The update dialog must use the user's saved interface language.
- Translation/meal source content may remain in its original language; describe its language accurately in every interface locale.

- After each application change, build and install the update on the user's phone over Wi-Fi, test the changed behavior on the phone, and report completion only after verification. If the phone is unavailable, report the blocker explicitly.
- Design and verify layouts for different phone and tablet sizes, in portrait and landscape; do not tailor behavior only to the Galaxy S24+. Use device display metrics for physical gesture distances.

- Keep the user-facing update notes short: list only newly added features in simple sentences. Omit implementation details and do not repeat previous releases.

- Do not display the developer's personal name or email address in app screens. Route contact through Support and feedback. Preserve the email recipient for composing a message, without a separate visible email label on the form.
