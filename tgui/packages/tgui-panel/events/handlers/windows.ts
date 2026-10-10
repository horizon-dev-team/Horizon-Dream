import {
  onPanelWindowClosed,
  onPanelWindowOpened,
} from '../../chat/chat-hover-strip';

export function panelWindowOpened(payload: { id?: string } | undefined) {
  if (typeof payload?.id === 'string') {
    onPanelWindowOpened(payload.id);
  }
}

export function panelWindowClosed(payload: { id?: string } | undefined) {
  if (typeof payload?.id === 'string') {
    onPanelWindowClosed(payload.id);
  }
}
