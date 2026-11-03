// ============================================================
// ShopBeta: MongoDB sample data (mongosh)
// MIT 8103 Advanced Database Systems - Portfolio 4
// Paste into the MONGOSH panel in Compass and press Enter.
// Creates database "shopbeta_nosql" with 200 products and 500 orders.
// All data is made up for this project.
// ============================================================

const sdb = db.getSiblingDB("shopbeta_nosql");
sdb.products.drop();
sdb.orders.drop();

const pick = (list) => list[Math.floor(Math.random() * list.length)];
const between = (min, max) => min + Math.floor(Math.random() * (max - min + 1));

const sellers = [
  { name: "DevlonHub",     city: "Lagos" },
  { name: "TechHub Lagos", city: "Lagos" },
  { name: "StyleHouse",    city: "Abuja" },
  { name: "HomeNest",      city: "Ibadan" },
  { name: "BookCorner",    city: "Port Harcourt" }
];

// Each category has DIFFERENT specs - this is where documents are flexible
const specsByCategory = {
  "Electronics": () => ({
    brand: pick(["Tecno", "Infinix", "Samsung", "Itel"]),
    ram: pick(["4GB", "6GB", "8GB"]),
    storage: pick(["64GB", "128GB", "256GB"]),
    warranty_months: pick([6, 12, 24])
  }),
  "Fashion": () => ({
    size: pick(["S", "M", "L", "XL"]),
    colour: pick(["black", "white", "blue", "red", "green"]),
    material: pick(["cotton", "linen", "denim"])
  }),
  "Home & Kitchen": () => ({
    material: pick(["steel", "plastic", "glass"]),
    capacity_litres: pick([1, 2, 5]),
    power_watts: pick([500, 1000, 1500])
  }),
  "Beauty": () => ({
    volume_ml: pick([50, 100, 250]),
    skin_type: pick(["dry", "oily", "all"])
  }),
  "Books": () => ({
    author: pick(["A. Okafor", "B. Adeyemi", "C. Bello"]),
    pages: between(120, 600),
    genre: pick(["fiction", "business", "science"])
  })
};

const categoryNames = Object.keys(specsByCategory);

// ---------- Products (200) ----------
const products = [];
for (let i = 1; i <= 200; i++) {
  const category = categoryNames[i % categoryNames.length];
  const reviews = [];
  for (let r = 0; r < between(0, 3); r++) {
    reviews.push({ rating: between(1, 5), comment: pick(["Good value", "Works well", "Fast delivery", "Not as described"]) });
  }
  products.push({
    product_id: i,
    name: category + " item " + i,
    category: category,
    price: between(500, 200000),
    stock_quantity: between(0, 500),
    seller: pick(sellers),
    specs: specsByCategory[category](),
    reviews: reviews
  });
}
sdb.products.insertMany(products);

// ---------- Orders (500): items are embedded inside each order ----------
const statuses = ["PENDING", "PAID", "SHIPPED", "DELIVERED", "CANCELLED"];
const orders = [];
for (let o = 1; o <= 500; o++) {
  const items = [];
  const used = new Set();
  const count = between(1, 3);
  while (items.length < count) {
    const p = pick(products);
    if (used.has(p.product_id)) continue;
    used.add(p.product_id);
    items.push({ product_id: p.product_id, name: p.name, quantity: between(1, 3), unit_price: p.price });
  }
  orders.push({
    order_id: o,
    customer: { name: "Customer " + between(1, 100), city: pick(["Lagos", "Abuja", "Ibadan"]) },
    items: items,
    total_amount: items.reduce((sum, it) => sum + it.quantity * it.unit_price, 0),
    status: pick(statuses),
    order_date: new Date(Date.now() - between(0, 365) * 86400000)
  });
}
sdb.orders.insertMany(orders);

// ---------- Check ----------
print("products: " + sdb.products.countDocuments());
print("orders:   " + sdb.orders.countDocuments());
