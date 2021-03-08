// function hideLoader() {
//     $('#loading').hide();
// }

// $(window).ready(hideLoader);

// // Strongly recommended: Hide loader after 30 seconds, even if the page hasn't finished loading
// setTimeout(hideLoader, 30 * 1000);

const displaySpinner = () => {
  const spinner = document.getElementById("loading");
  spinner.classList.remove("d-none");
}

const updateLoading = () => {
  const updateButton = document.getElementById("update-meetle");
  updateButton.addEventListener('click', displaySpinner);
}

export { updateLoading };
