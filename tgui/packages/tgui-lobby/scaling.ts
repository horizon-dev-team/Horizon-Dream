const REFERENCE_WIDTH = 880;
const REFERENCE_HEIGHT = 640;

export function updateScaling() {
  const scaleX = window.innerWidth / REFERENCE_WIDTH;
  const scaleY = window.innerHeight / REFERENCE_HEIGHT;
  const scale = Math.min(1, scaleX, scaleY);

  document.documentElement.style.setProperty(
    '--lobby-scale',
    `${scale}`,
  );
}
