import './styles/app.css';

import { Buffer } from 'buffer';
import App from './App.svelte';
import { setupI18n } from './i18n';
import { register, init, getLocaleFromNavigator } from 'svelte-i18n';
import { browserLangToLocaleKey } from './i18nLocal'
import { locales } from './i18nLocal'


Object.keys(locales).map(item => {
  register(item, () => import(`./locales/${item}.json`));
})

const initlang = browserLangToLocaleKey[getLocaleFromNavigator()]

init({
  fallbackLocale: 'en',
  initialLocale: initlang,
});

setupI18n({ withLocale: initlang });

const app = new App({
  target: document.getElementById('app'),
});

// @ts-ignore
window.Buffer = Buffer;

export default app;
