import { _, locale } from 'svelte-i18n';

function setupI18n({ withLocale: _locale } = { withLocale: 'en' }) {
  locale.set(_locale);
}

export { _, setupI18n };
