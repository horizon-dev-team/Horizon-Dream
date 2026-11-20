// This is the elements from the skin.dmf that we need to adjust the fontsize of
const ELEMENTS_TO_ADJUST = [
  'infobuttons.options',
  'infobuttons.hotkeys',
  'infobuttons.emotes',
  'infobuttons.fullscreen-toggle',
  'infobuttons.reconnect',
  'infobuttons.chat',
  'inputwindow.input',
  'inputbuttons.saybutton',
  'inputbuttons.mebutton',
  'inputbuttons.oocbutton',
  'inputbuttons.whisperbutton',
];

const DEFAULT_BUTTON_FONT_SIZE = 4;

export async function setDisplayScaling() {
  if (window.devicePixelRatio === 1) {
    return;
  }

  const newSizes: { [element: string]: number } = {};

  for (const element of ELEMENTS_TO_ADJUST) {
    newSizes[`${element}.font-size`] =
      DEFAULT_BUTTON_FONT_SIZE * window.devicePixelRatio;
  }

  Byond.winset(null, newSizes);
}
