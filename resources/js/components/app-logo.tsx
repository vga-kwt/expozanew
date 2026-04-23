export default function AppLogo() {
    return (
        <>
            <div className="aspect-square size-8">
                <img src={`${window.location.origin}/Group.svg`} alt="logo" />
            </div>
            <div className="ml-1 grid flex-1 text-left text-sm">
                <span className="mb-0.5 truncate leading-none font-semibold">Expoza</span>
            </div>
        </>
    );
}
