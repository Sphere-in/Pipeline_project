export default function Page() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">v1.0.1</h1>
        <p className="text-xl text-gray-600">Deployment Test Page</p>
        <div className="mt-8 text-sm text-gray-500">
          <p>Next.js App Router</p>
          <p className="mt-1">
            {new Date().toLocaleDateString("en-US", {
              year: "numeric",
              month: "long",
              day: "numeric",
            })}
          </p>
        </div>
      </div>
    </div>
  )
}
