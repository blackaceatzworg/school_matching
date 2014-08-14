function [ PrefSt ] = GeneratePreferences(Nsc, Nst, good, medium, bad)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

n=Nsc;

TopSchools=rand(Nst,ceil(Nsc*good));
[Y,I]=sort(TopSchools,2);
Tops=I;

n=n-ceil(Nsc*good);

MediumSchools=rand(Nst,ceil(Nsc*medium));
[Y,I]=sort(MediumSchools,2);
Meds=ceil(Nsc*good)+I;

n=n-ceil(Nsc*medium);

BadSchools=rand(Nst,n);
[Y,I]=sort(BadSchools,2);
Bads=ceil(Nsc*good)+ceil(Nsc*medium)+I;

PrefSt = [Tops Meds Bads];
end

