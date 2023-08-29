<script>
import { isLanguageModalOpen } from '../store/modalLanguage';
import { locales } from '../i18nLocal'
import { locale } from 'svelte-i18n';

function closeLangModal() {
    $isLanguageModalOpen = false
}

const onWindowKeydownPressed = (event) => {
    if (event.key === 'Escape') {
        $isLanguageModalOpen = false
    }
};

const switchLang = (value)=>{
    locale.set(value);
    isLanguageModalOpen.set(false);
}
</script>
  
  
<svelte:window on:keydown={onWindowKeydownPressed} />

<div class="language_modal">
    <div class="inner">
        <div class="Modal-header-wrapper">
            <div class="Modal-title-bar">
                <div class="Modal-title">Select Language</div>
                <div class="Modal-close-button">
                    <button type="button" class="cursor-pointer font-sans text-lg"
                        on:click={closeLangModal}>
                        &times;
                    </button>
                </div>
            </div>
        </div>
        <div class="dividerline"></div>
        <div class="languagebox">
            {#each Object.keys(locales) as item (item)}
                <div class="menu-item flexbox" on:keydown={onWindowKeydownPressed} on:click={() => switchLang(item)}>
                    <div class="menu-item-group fs12">{locales[item]}</div>
                    <div class="network-dropdown-menu-item-img flexbox">
                        {#if $locale === item}
                            <button type="button" class="cursor-pointer font-sans text-lg">
                                &check;
                            </button>
                        {/if}
                    </div>
                </div>
            {/each}
        </div>
    </div>
</div>