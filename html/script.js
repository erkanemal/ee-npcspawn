// Animation list with corrected dictionary
const animations = [
    { name: "Man standing still", dict: "amb@bagels@male@walking@", anim: "static" },
    { name: "Cowered 1 (Crouched)", dict: "amb@code_human_cower@female@base", anim: "base" },
    { name: "Cowered Standing 1", dict: "amb@code_human_cower_stand@female@base", anim: "base" },
    { name: "Crossing Road 1", dict: "amb@code_human_cross_road@female@base", anim: "base" },
    { name: "Sitting in Bus 1", dict: "amb@code_human_in_bus_passenger_idles@female@sit@base", anim: "base" }, // Corrected
    { name: "Sitting in Car 1", dict: "amb@code_human_in_car_idles@generic@ds@base", anim: "base" },
    { name: "Sitting in Van 1", dict: "amb@code_human_in_car_idles@van@ds@base", anim: "base" },
    { name: "Drinking Beer (Female)", dict: "amb@code_human_wander_drinking@beer@female@base", anim: "static" },
    { name: "Eating Donut (Male)", dict: "amb@code_human_wander_eating_donut@male@base", anim: "static" },
    { name: "Texting (Male)", dict: "amb@code_human_wander_texting@male@base", anim: "static" }
];

document.addEventListener('DOMContentLoaded', () => {
    console.log("UI Loaded");

    // Populate animation dropdown
    const animSelect = document.querySelector('.anim-select');
    animations.forEach(anim => {
        const option = document.createElement('option');
        option.value = JSON.stringify({ dict: anim.dict, name: anim.anim });
        option.textContent = anim.name;
        animSelect.appendChild(option);
    });

    // Handle Create button click
    document.querySelector('.create-border').addEventListener('click', () => {
        const model = document.querySelector('.npc-model-input').value.trim();
        const animData = JSON.parse(document.querySelector('.anim-select').value || '{}');
        const name = document.querySelector('.npc-name-input').value.trim();

        fetch(`https://${GetParentResourceName()}/createNPC`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: model,
                animDict: animData.dict || '',
                animName: animData.name || '',
                name: name
            })
        }).then(() => {
            toggleUI(false);
        });
    });

    // ESC key to close UI
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && document.querySelector('.main-container').style.display === 'block') {
            toggleUI(false);
        }
    });

    // Listen for messages from Lua
    window.addEventListener('message', (event) => {
        if (event.data.type === 'openUI') {
            console.log("Received openUI message");
            toggleUI(true);
        }
    });
});

function toggleUI(show) {
    const container = document.querySelector('.main-container');
    container.style.display = show ? 'block' : 'none';
    fetch(`https://${GetParentResourceName()}/toggleCursor`, {
        method: 'POST',
        body: JSON.stringify({ show: show })
    });
}