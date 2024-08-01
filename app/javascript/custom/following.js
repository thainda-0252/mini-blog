document.addEventListener("turbo:load", () => {
  const openFollowingModalButton = document.getElementById("open-following-modal");
  const closeFollowingModalButton = document.getElementById("close-following-modal");
  const followingModal = document.getElementById("following-modal");

  openFollowingModalButton?.addEventListener("click", () => {
    followingModal.classList.remove("hidden");
  });

  closeFollowingModalButton?.addEventListener("click", () => {
    followingModal.classList.add("hidden");
  });

  window.addEventListener("click", (event) => {
    if (event.target === followingModal) {
      followingModal.classList.add("hidden");
    }
  });
});
