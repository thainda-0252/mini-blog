document.addEventListener("turbo:load", () => {
  const openModalButton = document.getElementById("open-followers-modal");
  const closeModalButton = document.getElementById("close-followers-modal");
  const modal = document.getElementById("followers-modal");

  openModalButton?.addEventListener("click", () => {
    modal.classList.remove("hidden");
  });

  closeModalButton?.addEventListener("click", () => {
    modal.classList.add("hidden");
  });

  window.addEventListener("click", (event) => {
    if (event.target === modal) {
      modal.classList.add("hidden");
    }
  });
});
