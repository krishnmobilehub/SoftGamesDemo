document.onreadystatechange = () => {
    if (document.readyState === 'complete') {
        // get query string parameters from URL
        const getParams = (url) => {
            const params = {};
            const parser = document.createElement('a');
            parser.href = url;
            const query = parser.search.substring(1);
            const vars = query.split('&');
            for (let i = 0; i < vars.length; i++) {
                const pair = vars[i].split('=');
                params[pair[0]] = decodeURIComponent(pair[1]);
            }
            return params;
        };
        
        const params = getParams(window.location.href);

        function capitalizeFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        function getAge(dateString) {
            var today = new Date();
            var birthDate = new Date(dateString);
            var age = today.getFullYear() - birthDate.getFullYear();
            var m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
            return age;
        }
        
        const setValueInDocument = (key, val) => {
            // constants
            const row = document.getElementsByClassName('row')[0];
            const div = document.createElement('div');
            const label = document.createElement('label');
            const span = document.createElement('span');
            const boldElement = document.createElement('b');

            // set attributes
            label.innerHTML = capitalizeFirstLetter(key) + "&nbsp;&nbsp;&nbsp;";
            span.innerHTML = val;
            div.setAttribute('class', 'col-lg-12 col-md-12 col-sm-12 col-xs-12 d-flex align-items-center justify-content-center');

            // append child to body
            boldElement.appendChild(span);
            div.appendChild(label).appendChild(boldElement);
            row.appendChild(div);
        }
        
        for(const key of Object.keys(params)) {
            setValueInDocument(key, key === "Age" ? getAge(params[key]) : params[key]);
        }
    }
};
