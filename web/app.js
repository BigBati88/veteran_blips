const dealer = document.getElementById('dealer');
const categoriesElement = document.getElementById('categories');
const vehiclesElement = document.getElementById('vehicles');
const timerElement = document.getElementById('timer');
const testDurationElement = document.getElementById('test-duration');
let categories = [];
let selectedCategory = 0;

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'veteran_blips';
const post = (endpoint, data = {}) => fetch(`https://${resource}/${endpoint}`, { method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(data) });
const formatPrice = (price) => `$${new Intl.NumberFormat('en-US').format(price)}`;
const formatTime = (seconds) => `${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;

function render() {
  categoriesElement.innerHTML = categories.map((category, index) => `<button class="${index === selectedCategory ? 'active' : ''}" data-category="${index}">${category.label}</button>`).join('');
  const vehicles = categories[selectedCategory]?.vehicles || [];
  vehiclesElement.innerHTML = vehicles.map((vehicle) => `<article class="vehicle"><h3>${vehicle.label}</h3><span class="price">${formatPrice(vehicle.price)}</span><div class="actions"><button data-test="${vehicle.model}">Tesztvezetés</button><button class="buy" data-buy="${vehicle.model}">Megveszem</button></div></article>`).join('');
}

categoriesElement.addEventListener('click', (event) => { if (event.target.dataset.category) { selectedCategory = Number(event.target.dataset.category); render(); } });
vehiclesElement.addEventListener('click', (event) => { const model = event.target.dataset.test || event.target.dataset.buy; if (!model) return; post(event.target.dataset.test ? 'testDrive' : 'buyVehicle', { model }); });
document.getElementById('close').addEventListener('click', () => post('close'));
window.addEventListener('keydown', (event) => { if (event.key === 'Escape') post('close'); });
window.addEventListener('message', ({ data }) => {
  if (data.action === 'open') { categories = data.categories || []; selectedCategory = 0; testDurationElement.textContent = formatTime(data.testSeconds || 120); dealer.classList.remove('hidden'); render(); }
  if (data.action === 'close') dealer.classList.add('hidden');
  if (data.action === 'timer') timerElement.textContent = data.seconds > 0 ? `Tesztvezetés: ${formatTime(data.seconds)}` : '';
});
