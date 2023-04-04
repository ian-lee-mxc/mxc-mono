import { writable } from 'svelte/store';
import { ETHToken, MXCToken } from '../token/tokens';
import type { Token } from '../domain/token';

// export const token = writable<Token>(ETHToken);
export const token = writable<Token>(MXCToken);

