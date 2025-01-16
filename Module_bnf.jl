
module Module_bnf
using Serialization

export desreialisation, bnf
"""
Module_bnf.jl Crée la banque de données du serveur TCP de riboDB
(bnf en hommage à la BNF)
Copyright or © or Copr. UCBL Lyon, France;  
contributor : [Jean-Pierre Flandrois] ([2024/12/20])
[JP.flandrois@univ-lyon1.fr]

This software is a computer program whose purpose is to create a TCP server interface to the riboDB sequence database.

This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.

"""
function lisclasseur(classeur::String,tagjoin::Bool)
    classeur[end] == '/' ? classeur=classeur[1:(end-1)] : classeur
    monclasseur::Vector{String}=[]
    tagjoin ? monclasseur=readdir(classeur,join=true) : monclasseur=readdir(classeur)
    deleteat!(monclasseur,findall(x->x==".DS_Store",monclasseur)) #.DS_Store
    deleteat!(monclasseur,findall(x->x==classeur*"/.DS_Store",monclasseur)) #.DS_Store
    return monclasseur
end

function desreialisation(inputfile::String)
    monfastamiracle::Dict{String,String}=Dict([])
    monfastamiracle=deserialize(inputfile)
end

function bnf()
    diris="BNKriboDB_SER"
    lescibles::Vector{String}=lisclasseur(diris,true)
    gallica::Dict{String,Dict{String,Dict{String,String}}}=Dict([])
    #println(lescibles)
    for sc in lescibles#[1:2] #cas des testts
        prot::SubString{String}=splitpath(sc)[end]
        #println(prot)
        #subgreatdirout=joinpath("/Users/jean-pierreflandrois/Documents/Xtract/",prot)
        subcibles::Vector{String}=lisclasseur(sc,true)
        #println(subcibles)
        gallica[prot]=Dict([])
        for subsc in subcibles
            #println(prot,"   ",split(splitpath(subsc)[end],'.')[1])
             #split(splitpath(subsc)[end],'.')[1]
            gallica[prot][split(splitpath(subsc)[end],'.')[1]]=desreialisation(subsc)
        end 
    end
    # println(length(gallica))
    #println(keys(gallica))
    #resu=tordue(gallica,cibles,["Enterobacterales"],["#E"],"/Users/jean-pierreflandrois/Documents/Xtract/")
    # pas une bonne idee 
    # serialize("GALLICA.ser", gallica)
    println("gallica fait")
    return gallica
end

# function statistiquesbnf(diori)
# #seulement la lecture des données
# diris="STATSRIBODB"
# encyclop::Dict{String,Vector{Int64}}=deserialize(joinpath(diris,"ENCYCLOPRIBODB.ser"))
# titres::Vector{String}=deserialize(joinpath(diris,"TITRESENCYCLOP.ser"))
# return(titres,encyclop)
# end



end #fin module