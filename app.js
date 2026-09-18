(() => {
  const toggle = document.getElementById("languageToggle");
  const nodes = Array.from(document.querySelectorAll("[data-ko][data-en]"));
  const original = new Map(nodes.map((el) => [el, el.innerHTML]));
  const KEY = "dn-lang";

  function apply(lang) {
    nodes.forEach((el) => {
      if (lang === "ko") el.innerHTML = original.get(el);
      else el.textContent = el.dataset.en;
    });
    document.documentElement.lang = lang;
    toggle.textContent = lang === "ko" ? "EN" : "한글";
    toggle.setAttribute("aria-label", lang === "ko" ? "Switch to English" : "한국어로 보기");
    try { localStorage.setItem(KEY, lang); } catch (_) {}
  }

  let lang = "ko";
  try { if (localStorage.getItem(KEY) === "en") lang = "en"; } catch (_) {}
  if (lang === "en") apply("en");

  toggle.addEventListener("click", () => {
    lang = lang === "ko" ? "en" : "ko";
    apply(lang);
  });
})();
