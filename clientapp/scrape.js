var batch = 168;
collect = [];
document.querySelectorAll('.myarticlelist li.itemdata ul.clearfix').forEach(function (i, e) {
    let sub=i.querySelector('li.additional span');
    if(sub!==null){
        let ni= {batch: batch};
        let amount = sub.innerText.replace('Anzahl:', '');
        ni['amount'] = amount;
        let desc$ = i.querySelector('li.description');
        ni['artnr'] = desc$.querySelector('a span').innerText;
        ni['description'] = desc$.querySelector('span.al_artinfo_link').innerText;
        collect.push(ni);
    }

});
