// Lookup table from model class label -> plant, diagnosis title, and care advice.
// Keys must match entries in CLASS_NAMES exactly.
const Map<String, Map<String, String>> REMEDIATION_DATA = {
  "Apple___Apple_scab": {
    "Plant": "Apple",
    "title": "Apple Scab",
    "advice":
        "Remove infected leaves and fruit. Prune trees to improve airflow. Avoid overhead irrigation and apply fungicides such as captan or sulfur during the growing season.",
    "risk": "Medium",
  },
  "Apple___Black_rot": {
    "Plant": "Apple",
    "title": "Black Rot",
    "advice":
        "Remove mummified fruit and infected branches. Prune for airflow and apply fungicides early in the season.",
    "risk": "High",
  },
  "Apple___Cedar_apple_rust": {
    "Plant": "Apple",
    "title": "Cedar Apple Rust",
    "advice":
        "Remove nearby cedar/juniper hosts if possible. Apply fungicides during early leaf development and plant resistant varieties.",
    "risk": "Medium",
  },
  "Apple___healthy": {
    "Plant": "Apple",
    "title": "Healthy",
    "advice":
        "No treatment required. Continue regular monitoring, watering, and fertilization.",
    "risk": "Low",
  },
  "Blueberry___healthy": {
    "Plant": "Blueberry",
    "title": "Healthy",
    "advice":
        "Maintain proper soil acidity, good drainage, and monitor plants regularly.",
    "risk": "Low",
  },
  "Cherry_(including_sour)___Powdery_mildew": {
    "Plant": "Cherry",
    "title": "Powdery Mildew",
    "advice":
        "Prune to improve air circulation. Remove infected leaves and apply sulfur or fungicide sprays.",
    "risk": "Medium",
  },
  "Cherry_(including_sour)___healthy": {
    "Plant": "Cherry",
    "title": "Healthy",
    "advice":
        "No treatment required. Maintain proper pruning and irrigation practices.",
    "risk": "Low",
  },
  "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot": {
    "Plant": "Corn",
    "title": "Gray Leaf Spot",
    "advice":
        "Use resistant hybrids, rotate crops, and apply foliar fungicides if infection becomes severe.",
    "risk": "High",
  },
  "Corn_(maize)___Common_rust_": {
    "Plant": "Corn",
    "title": "Common Rust",
    "advice":
        "Plant resistant varieties and apply fungicides if rust spreads significantly.",
    "risk": "Medium",
  },
  "Corn_(maize)___Northern_Leaf_Blight": {
    "Plant": "Corn",
    "title": "Northern Leaf Blight",
    "advice":
        "Use resistant hybrids, rotate crops, and apply fungicides during early disease development.",
    "risk": "High",
  },
  "Corn_(maize)___healthy": {
    "Plant": "Corn",
    "title": "Healthy",
    "advice":
        "Continue proper fertilization, irrigation, and crop rotation practices.",
    "risk": "Low",
  },
  "Grape___Black_rot": {
    "Plant": "Grape",
    "title": "Black Rot",
    "advice":
        "Remove infected fruit and leaves. Improve airflow with pruning and apply fungicides early in the season.",
    "risk": "High",
  },
  "Grape___Esca_(Black_Measles)": {
    "Plant": "Grape",
    "title": "Esca (Black Measles)",
    "advice":
        "Remove infected wood and vines if severe. Avoid pruning wounds during wet conditions.",
    "risk": "High",
  },
  "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": {
    "Plant": "Grape",
    "title": "Leaf Blight",
    "advice":
        "Remove infected leaves, improve airflow, and apply fungicides when symptoms first appear.",
    "risk": "Medium",
  },
  "Grape___healthy": {
    "Plant": "Grape",
    "title": "Healthy",
    "advice": "Maintain proper pruning and vineyard sanitation practices.",
    "risk": "Low",
  },
  "Orange___Haunglongbing_(Citrus_greening)": {
    "Plant": "Orange",
    "title": "Citrus Greening",
    "advice":
        "Remove infected trees immediately to prevent spread. Control psyllid insect vectors and use certified disease-free plants.",
    "risk": "Very High",
  },
  "Peach___Bacterial_spot": {
    "Plant": "Peach",
    "title": "Bacterial Spot",
    "advice":
        "Apply copper sprays early in the season and plant resistant varieties where possible.",
    "risk": "Medium",
  },
  "Peach___healthy": {
    "Plant": "Peach",
    "title": "Healthy",
    "advice": "Continue routine orchard maintenance and monitoring.",
    "risk": "Low",
  },
  "Pepper,_bell___Bacterial_spot": {
    "Plant": "Bell Pepper",
    "title": "Bacterial Spot",
    "advice":
        "Use certified seeds, rotate crops, remove infected plants, and apply copper bactericides.",
    "risk": "High",
  },
  "Pepper,_bell___healthy": {
    "Plant": "Bell Pepper",
    "title": "Healthy",
    "advice": "Maintain proper watering and monitor for pests or disease.",
    "risk": "Low",
  },
  "Potato___Early_blight": {
    "Plant": "Potato",
    "title": "Early Blight",
    "advice":
        "Rotate crops, remove infected leaves, and apply fungicides when symptoms first appear.",
    "risk": "High",
  },
  "Potato___Late_blight": {
    "Plant": "Potato",
    "title": "Late Blight",
    "advice":
        "Remove infected plants immediately, avoid overhead irrigation, and apply protective fungicides.",
    "risk": "Very High",
  },
  "Potato___healthy": {
    "Plant": "Potato",
    "title": "Healthy",
    "advice": "Maintain proper crop rotation and soil health.",
    "risk": "Low",
  },
  "Raspberry___healthy": {
    "Plant": "Raspberry",
    "title": "Healthy",
    "advice": "Continue routine pruning and pest monitoring.",
    "risk": "Low",
  },
  "Soybean___healthy": {
    "Plant": "Soybean",
    "title": "Healthy",
    "advice": "Maintain proper fertilization and monitor for pests.",
    "risk": "Low",
  },
  "Squash___Powdery_mildew": {
    "Plant": "Squash",
    "title": "Powdery Mildew",
    "advice":
        "Remove infected leaves, improve airflow, and apply fungicides such as sulfur or potassium bicarbonate.",
    "risk": "Medium",
  },
  "Strawberry___Leaf_scorch": {
    "Plant": "Strawberry",
    "title": "Leaf Scorch",
    "advice":
        "Remove infected foliage, avoid overhead watering, and apply fungicides if severe.",
    "risk": "Medium",
  },
  "Strawberry___healthy": {
    "Plant": "Strawberry",
    "title": "Healthy",
    "advice": "Maintain good watering practices and monitor for disease.",
    "risk": "Low",
  },
  "Tomato___Bacterial_spot": {
    "Plant": "Tomato",
    "title": "Bacterial Spot",
    "advice":
        "Remove infected plants, rotate crops, and apply copper-based bactericides.",
    "risk": "High",
  },
  "Tomato___Early_blight": {
    "Plant": "Tomato",
    "title": "Early Blight",
    "advice":
        "Remove infected leaves, rotate crops, and apply fungicides regularly.",
    "risk": "High",
  },
  "Tomato___Late_blight": {
    "Plant": "Tomato",
    "title": "Late Blight",
    "advice":
        "Remove infected plants immediately and apply protective fungicides to surrounding plants.",
    "risk": "Very High",
  },
  "Tomato___Leaf_Mold": {
    "Plant": "Tomato",
    "title": "Leaf Mold",
    "advice":
        "Improve greenhouse ventilation, avoid leaf wetness, and apply fungicides.",
    "risk": "Medium",
  },
  "Tomato___Septoria_leaf_spot": {
    "Plant": "Tomato",
    "title": "Septoria Leaf Spot",
    "advice":
        "Remove infected leaves, mulch soil to prevent splash, and apply fungicides.",
    "risk": "Medium",
  },
  "Tomato___Spider_mites Two-spotted_spider_mite": {
    "Plant": "Tomato",
    "title": "Spider Mites",
    "advice":
        "Spray plants with water to reduce mites, introduce beneficial insects, or apply miticides.",
    "risk": "Medium",
  },
  "Tomato___Target_Spot": {
    "Plant": "Tomato",
    "title": "Target Spot",
    "advice":
        "Remove infected leaves and apply fungicides. Maintain proper spacing for airflow.",
    "risk": "Medium",
  },
  "Tomato___Tomato_Yellow_Leaf_Curl_Virus": {
    "Plant": "Tomato",
    "title": "Yellow Leaf Curl Virus",
    "advice":
        "Remove infected plants and control whitefly populations using insecticides or netting.",
    "risk": "Very High",
  },
  "Tomato___Tomato_mosaic_virus": {
    "Plant": "Tomato",
    "title": "Tomato Mosaic Virus",
    "advice":
        "Remove infected plants and disinfect tools. Avoid handling plants after tobacco exposure.",
    "risk": "High",
  },
  "Tomato___healthy": {
    "Plant": "Tomato",
    "title": "Healthy",
    "advice": "Maintain proper watering, fertilization, and monitoring.",
    "risk": "Low",
  },
};
