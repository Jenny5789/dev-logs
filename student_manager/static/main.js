// 알림 메시지 3초 후 자동 제거
document.querySelectorAll(".alert").forEach(el => {
  setTimeout(() => el.style.opacity = "0", 2800);
  setTimeout(() => el.remove(), 3200);
  el.style.transition = "opacity .4s";
});